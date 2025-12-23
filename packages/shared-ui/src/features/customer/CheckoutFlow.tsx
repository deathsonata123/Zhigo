//src/app/checkout/page.tsx
'use client';

import { Suspense, useState, useEffect } from 'react';
import { useSearchParams, useRouter } from 'next/navigation';
import { Button } from '../../components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '../../components/ui/card';
import { Input } from '../../components/ui/input';
import { Separator } from '../../components/ui/separator';
import Image from 'next/image';
import { Loader2, MapPin, Wallet, CreditCard, Smartphone, Trash2, Plus, Minus } from 'lucide-react';
import Link from 'next/link';
import { Label } from '../../components/ui/label';
import { RadioGroup, RadioGroupItem } from '../../components/ui/radio-group';
import { Textarea } from '../../components/ui/textarea';
import { useToast } from '../../hooks/use-toast';
import { getCurrentUser } from '../../lib/auth';


type CartItem = MenuItem & { quantity: number };

const PAYMENT_METHODS = [
    { id: 'cod', name: 'Cash on Delivery', icon: Wallet, enabled: true },
    { id: 'bkash', name: 'bKash', icon: Smartphone, enabled: true },
    { id: 'nagad', name: 'Nagad', icon: Smartphone, enabled: true },
    { id: 'card', name: 'Credit/Debit Card', icon: CreditCard, enabled: true },
];

function CheckoutPageContent() {
    const searchParams = useSearchParams();
    const router = useRouter();
    const { toast } = useToast();

    const cartString = searchParams.get('cart');
    const restaurantName = searchParams.get('restaurantName');
    const restaurantImage = searchParams.get('restaurantImage');
    const restaurantId = searchParams.get('restaurantId');

    const [cart, setCart] = useState<CartItem[]>(cartString ? JSON.parse(cartString) : []);
    const [selectedTip, setSelectedTip] = useState(20);
    const [paymentMethod, setPaymentMethod] = useState('cod');
    const [noteToRider, setNoteToRider] = useState('');
    const [noteToRestaurant, setNoteToRestaurant] = useState('');
    const [isPlacingOrder, setIsPlacingOrder] = useState(false);

    // Customer info - EDITABLE (will be fetched from database)
    const [customerName, setCustomerName] = useState('');
    const [customerPhone, setCustomerPhone] = useState('');
    const [customerAddress, setCustomerAddress] = useState('');
    const [customerEmail, setCustomerEmail] = useState('');
    const [loadingCustomer, setLoadingCustomer] = useState(true);
    const [deliveryZone] = useState('Mohammadpur');

    const tipAmounts = [0, 10, 20, 30, 50];

    // Fetch customer data
    useEffect(() => {
        fetchCustomerData();
    }, []);

    // Update cart in localStorage when it changes
    useEffect(() => {
        if (cart.length > 0) {
            localStorage.setItem('cart', JSON.stringify(cart));
            window.dispatchEvent(new Event('cartUpdated'));
        }
    }, [cart]);

    const fetchCustomerData = async () => {
        try {
            const user = await getCurrentUser();

            const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://52.74.236.219:3000';

            // Try to get customer profile
            const customersRes = await fetch(`${apiUrl}/api/users?userId=${user.userId}`);
            if (customersRes.ok) {
                const customers = await customersRes.json();

                if (customers && customers.length > 0) {
                    const customer = customers[0];
                    setCustomerName(customer.fullName || '');
                    setCustomerPhone(customer.phone || '');
                    setCustomerAddress(customer.addresses || '');
                    setCustomerEmail(customer.email || user.signInDetails?.loginId || '');
                } else {
                    // Use user email as fallback
                    setCustomerEmail(user.signInDetails?.loginId || '');
                }
            } else {
                // Use user email as fallback
                setCustomerEmail(user.signInDetails?.loginId || '');
            }
        } catch (error) {
            console.log('Not authenticated or error fetching customer:', error);
        } finally {
            setLoadingCustomer(false);
        }
    };

    const subtotal = cart.reduce((acc, item) => acc + item.price * item.quantity, 0);

    // Calculate fees
    const deliveryFee = 34.00;
    const serviceFee = subtotal > 0 ? 3.00 : 0;
    const vat = subtotal > 0 ? 23.00 : 0;
    const total = subtotal + deliveryFee + serviceFee + vat + selectedTip;

    const removeItem = (itemId: string) => {
        const updatedCart = cart.filter(item => item.id !== itemId);
        setCart(updatedCart);

        if (updatedCart.length === 0) {
            localStorage.removeItem('cart');
            window.dispatchEvent(new Event('cartUpdated'));
            toast({
                title: "Cart Emptied",
                description: "All items removed from cart",
            });
        }
    };

    const updateQuantity = (itemId: string, newQuantity: number) => {
        if (newQuantity < 1) {
            removeItem(itemId);
            return;
        }

        const updatedCart = cart.map(item =>
            item.id === itemId ? { ...item, quantity: newQuantity } : item
        );
        setCart(updatedCart);
    };

    const handlePlaceOrder = async () => {
        // Validation
        if (!customerName.trim() || !customerPhone.trim() || !customerAddress.trim()) {
            toast({
                title: "Missing Information",
                description: "Please fill in all delivery details",
                variant: "destructive"
            });
            return;
        }

        if (!restaurantId || !restaurantName) {
            toast({
                title: "Error",
                description: "Restaurant information missing",
                variant: "destructive"
            });
            return;
        }

        if (cart.length === 0) {
            toast({
                title: "Empty Cart",
                description: "Please add items to your cart",
                variant: "destructive"
            });
            return;
        }

        setIsPlacingOrder(true);

        try {
            console.log('📦 Placing order for restaurant:', restaurantId);

            // Get restaurant data to fetch its coordinates
            const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://52.74.236.219:3000';
            const restaurantRes = await fetch(`${apiUrl}/api/restaurants/${restaurantId}`);

            if (!restaurantRes.ok) {
                console.error('❌ Restaurant fetch error:', restaurantRes.statusText);
                toast({
                    title: "Error",
                    description: "Restaurant not found",
                    variant: "destructive"
                });
                return;
            }

            const restaurant = await restaurantRes.json();

            console.log('🏪 Restaurant data:', restaurant);

            // Geocode customer address to get lat/lng
            let customerLat = 23.7805; // Default Dhaka coordinates
            let customerLng = 90.4200;

            try {
                const mapboxToken = process.env.NEXT_PUBLIC_MAPBOX_ACCESS_TOKEN;

                if (mapboxToken) {
                    const geocodeUrl = `https://api.mapbox.com/geocoding/v5/mapbox.places/${encodeURIComponent(customerAddress + ', Dhaka, Bangladesh')}.json?access_token=${mapboxToken}&limit=1`;

                    console.log('🗺️ Geocoding customer address...');
                    const geocodeResponse = await fetch(geocodeUrl);
                    const geocodeData = await geocodeResponse.json();

                    if (geocodeData.features && geocodeData.features.length > 0) {
                        customerLng = geocodeData.features[0].center[0];
                        customerLat = geocodeData.features[0].center[1];
                        console.log('✅ Customer location geocoded:', customerLat, customerLng);
                    } else {
                        console.warn('⚠️ No geocoding results, using default location');
                    }
                } else {
                    console.warn('⚠️ Mapbox token not found, using default location');
                }
            } catch (geocodeError) {
                console.warn('⚠️ Geocoding failed, using default location:', geocodeError);
            }

            // Prepare order items
            const orderItems = cart.map(item => ({
                id: item.id,
                name: item.name,
                price: item.price,
                quantity: item.quantity
            }));

            console.log('📝 Creating order with items:', orderItems.length);

            // Create order with location data
            const orderRes = await fetch(`${apiUrl}/api/orders`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    restaurantId,
                    restaurantName,
                    customerName: customerName.trim(),
                    customerPhone: customerPhone.trim(),
                    customerAddress: customerAddress.trim(),
                    customerEmail: customerEmail.trim() || 'customer@example.com',
                    deliveryZone,
                    noteToRider: noteToRider.trim() || undefined,
                    noteToRestaurant: noteToRestaurant.trim() || undefined,
                    items: JSON.stringify(orderItems),
                    subtotal,
                    deliveryFee,
                    serviceFee,
                    vat,
                    tip: selectedTip,
                    total,
                    paymentMethod: paymentMethod,
                    paymentStatus: 'pending',
                    status: 'pending',
                    restaurantLatitude: restaurant.latitude || 23.8103,
                    restaurantLongitude: restaurant.longitude || 90.4125,
                    customerLatitude: customerLat,
                    customerLongitude: customerLng,
                    createdAt: new Date().toISOString(),
                })
            });

            if (!orderRes.ok) {
                const orderErrors = await orderRes.json();
                console.error('❌ Order creation errors:', orderErrors);
                toast({
                    title: "Error",
                    description: "Failed to place order. Please try again.",
                    variant: "destructive"
                });
                return;
            }

            const newOrder = await orderRes.json();

            console.log('✅ Order created successfully:', newOrder?.id);

            // Clear cart
            localStorage.removeItem('cart');
            window.dispatchEvent(new Event('cartUpdated'));

            toast({
                title: "Order Placed! 🎉",
                description: `Order #${newOrder?.id.slice(0, 8)} has been sent to ${restaurantName}`,
            });

            // Redirect to home page
            router.push(`/?orderId=${newOrder?.id}`);

        } catch (error) {
            console.error('❌ Error placing order:', error);
            toast({
                title: "Error",
                description: "An error occurred. Please try again.",
                variant: "destructive"
            });
        } finally {
            setIsPlacingOrder(false);
        }
    };

    if (loadingCustomer) {
        return (
            <div className="flex items-center justify-center min-h-screen">
                <Loader2 className="h-8 w-8 animate-spin" />
            </div>
        );
    }

    if (cart.length === 0) {
        return (
            <div className="bg-muted/30 min-h-screen">
                <div className="container mx-auto py-8 px-4">
                    <Card className="max-w-md mx-auto">
                        <CardHeader>
                            <CardTitle className="font-headline">Your cart is empty</CardTitle>
                            <CardDescription>Add some delicious items to get started!</CardDescription>
                        </CardHeader>
                        <CardContent>
                            <Button onClick={() => router.push('/restaurants')} className="w-full">
                                Browse Restaurants
                            </Button>
                        </CardContent>
                    </Card>
                </div>
            </div>
        );
    }

    return (
        <div className="bg-muted/30 min-h-screen">
            <div className="container mx-auto py-8 px-4">
                <header className="mb-6">
                    {restaurantName && restaurantId && (
                        <Link href={`/restaurants/${restaurantId}`}>
                            <div className="flex items-center gap-4 group">
                                {restaurantImage && (
                                    <Image
                                        src={restaurantImage}
                                        alt={restaurantName}
                                        width={48}
                                        height={48}
                                        className="rounded-full"
                                    />
                                )}
                                <div>
                                    <p className="text-sm text-muted-foreground group-hover:text-primary">Your order from</p>
                                    <h1 className="text-2xl font-bold font-headline group-hover:text-primary">{restaurantName}</h1>
                                </div>
                            </div>
                        </Link>
                    )}
                </header>

                <div className="grid grid-cols-1 lg:grid-cols-5 gap-8">
                    <main className="lg:col-span-3">
                        <div className="space-y-6">
                            <h2 className="text-3xl font-bold font-headline mb-2">Review and place your order</h2>

                            {/* Delivery Address - EDITABLE */}
                            <Card>
                                <CardHeader>
                                    <CardTitle className="font-headline">Delivery Details</CardTitle>
                                    <CardDescription>Update your delivery information</CardDescription>
                                </CardHeader>
                                <CardContent className="space-y-4">
                                    <div className="space-y-2">
                                        <Label htmlFor="name">Your Name *</Label>
                                        <Input
                                            id="name"
                                            value={customerName}
                                            onChange={(e) => setCustomerName(e.target.value)}
                                            placeholder="Enter your name"
                                        />
                                    </div>

                                    <div className="space-y-2">
                                        <Label htmlFor="phone">Phone Number *</Label>
                                        <Input
                                            id="phone"
                                            value={customerPhone}
                                            onChange={(e) => setCustomerPhone(e.target.value)}
                                            placeholder="01XXXXXXXXX"
                                        />
                                    </div>

                                    <div className="space-y-2">
                                        <Label htmlFor="email">Email</Label>
                                        <Input
                                            id="email"
                                            type="email"
                                            value={customerEmail}
                                            onChange={(e) => setCustomerEmail(e.target.value)}
                                            placeholder="your@email.com"
                                        />
                                    </div>

                                    <div className="space-y-2">
                                        <Label htmlFor="address">Delivery Address *</Label>
                                        <Textarea
                                            id="address"
                                            value={customerAddress}
                                            onChange={(e) => setCustomerAddress(e.target.value)}
                                            placeholder="House/Flat, Road, Area"
                                            rows={3}
                                        />
                                        <p className="text-sm text-muted-foreground">Zone: {deliveryZone}</p>
                                    </div>

                                    <div className="space-y-2">
                                        <Label htmlFor="noteRest">Note to Restaurant (Optional)</Label>
                                        <Textarea
                                            id="noteRest"
                                            placeholder="e.g. Extra spicy, no onions"
                                            value={noteToRestaurant}
                                            onChange={(e) => setNoteToRestaurant(e.target.value)}
                                            rows={2}
                                        />
                                    </div>

                                    <div className="space-y-2">
                                        <Label htmlFor="noteRider">Note to Rider (Optional)</Label>
                                        <Textarea
                                            id="noteRider"
                                            placeholder="e.g. Ring the bell, building landmark"
                                            value={noteToRider}
                                            onChange={(e) => setNoteToRider(e.target.value)}
                                            rows={2}
                                        />
                                    </div>
                                </CardContent>
                            </Card>

                            {/* Cart Items */}
                            <Card>
                                <CardHeader>
                                    <CardTitle className="font-headline">Your Items</CardTitle>
                                    <CardDescription>Review and modify your order</CardDescription>
                                </CardHeader>
                                <CardContent className="space-y-4">
                                    {cart.map(item => (
                                        <div key={item.id} className="flex items-center gap-4 p-4 bg-muted/50 rounded-lg">
                                            <div className="flex-1">
                                                <h3 className="font-semibold">{item.name}</h3>
                                                <p className="text-sm text-muted-foreground">Tk {item.price} each</p>
                                            </div>

                                            <div className="flex items-center gap-2">
                                                <Button
                                                    variant="outline"
                                                    size="icon"
                                                    className="h-8 w-8"
                                                    onClick={() => updateQuantity(item.id, item.quantity - 1)}
                                                >
                                                    <Minus className="h-4 w-4" />
                                                </Button>
                                                <span className="font-semibold w-8 text-center">
                                                    {item.quantity}
                                                </span>
                                                <Button
                                                    variant="outline"
                                                    size="icon"
                                                    className="h-8 w-8"
                                                    onClick={() => updateQuantity(item.id, item.quantity + 1)}
                                                >
                                                    <Plus className="h-4 w-4" />
                                                </Button>
                                            </div>

                                            <div className="text-right min-w-[80px]">
                                                <p className="font-bold">
                                                    Tk {(item.price * item.quantity).toFixed(2)}
                                                </p>
                                            </div>

                                            <Button
                                                variant="ghost"
                                                size="icon"
                                                className="text-destructive hover:text-destructive hover:bg-destructive/10"
                                                onClick={() => removeItem(item.id)}
                                            >
                                                <Trash2 className="h-5 w-5" />
                                            </Button>
                                        </div>
                                    ))}
                                </CardContent>
                            </Card>

                            {/* Payment Method */}
                            <Card>
                                <CardHeader>
                                    <CardTitle className="font-headline">Payment method</CardTitle>
                                    <CardDescription>How would you like to pay?</CardDescription>
                                </CardHeader>
                                <CardContent>
                                    <RadioGroup value={paymentMethod} onValueChange={setPaymentMethod} className="space-y-3">
                                        {PAYMENT_METHODS.map((method) => (
                                            <div
                                                key={method.id}
                                                className="flex items-center justify-between p-4 border rounded-md has-[:checked]:bg-primary/5 has-[:checked]:border-primary cursor-pointer"
                                            >
                                                <div className="flex items-center gap-3">
                                                    <RadioGroupItem value={method.id} id={method.id} />
                                                    <Label htmlFor={method.id} className="font-medium cursor-pointer flex items-center gap-2">
                                                        <method.icon className="h-5 w-5 text-primary" />
                                                        {method.name}
                                                    </Label>
                                                </div>
                                            </div>
                                        ))}
                                    </RadioGroup>
                                </CardContent>
                            </Card>

                            {/* Tip */}
                            <Card>
                                <CardHeader>
                                    <CardTitle className="font-headline">Tip your rider</CardTitle>
                                    <CardDescription>Your rider receives 100% of the tip.</CardDescription>
                                </CardHeader>
                                <CardContent>
                                    <div className="flex flex-wrap gap-2">
                                        {tipAmounts.map(amount => (
                                            <Button
                                                key={amount}
                                                variant={selectedTip === amount ? 'default' : 'outline'}
                                                onClick={() => setSelectedTip(amount)}
                                                className="flex-1"
                                            >
                                                {amount === 0 ? 'Not now' : `Tk ${amount}`}
                                            </Button>
                                        ))}
                                    </div>
                                </CardContent>
                            </Card>

                            {/* Place Order Button */}
                            <Button
                                size="lg"
                                className="w-full text-lg"
                                onClick={handlePlaceOrder}
                                disabled={isPlacingOrder || cart.length === 0}
                            >
                                {isPlacingOrder ? (
                                    <>
                                        <Loader2 className="mr-2 h-5 w-5 animate-spin" />
                                        Placing Order...
                                    </>
                                ) : (
                                    `Place Order - Tk ${total.toFixed(2)}`
                                )}
                            </Button>
                            <p className="text-xs text-muted-foreground text-center">
                                By making this purchase you agree to our terms and conditions.
                            </p>
                        </div>
                    </main>

                    <aside className="lg:col-span-2">
                        <Card className="p-6 sticky top-24">
                            <CardHeader className="p-0 mb-4">
                                <CardTitle className="font-headline text-xl">Your order</CardTitle>
                                <CardDescription>{restaurantName}</CardDescription>
                            </CardHeader>

                            <Separator />

                            <div className="space-y-4 max-h-60 overflow-y-auto pr-2 my-4">
                                {cart.map(item => (
                                    <div key={item.id} className="flex justify-between items-start gap-4">
                                        <div className="flex items-start gap-3">
                                            <p className="text-sm font-medium shrink-0">{item.quantity}x</p>
                                            <div>
                                                <p className="font-medium text-sm">{item.name}</p>
                                            </div>
                                        </div>
                                        <p className="text-sm font-semibold shrink-0">Tk {(item.price * item.quantity).toFixed(2)}</p>
                                    </div>
                                ))}
                            </div>

                            <Separator className="my-4" />

                            <div className="space-y-2 text-sm">
                                <div className="flex justify-between">
                                    <p>Subtotal</p>
                                    <p>Tk {subtotal.toFixed(2)}</p>
                                </div>
                                <div className="flex justify-between">
                                    <p>Delivery Fee</p>
                                    <p>Tk {deliveryFee.toFixed(2)}</p>
                                </div>
                                <div className="flex justify-between">
                                    <p>Service Fee</p>
                                    <p>Tk {serviceFee.toFixed(2)}</p>
                                </div>
                                <div className="flex justify-between">
                                    <p>VAT</p>
                                    <p>Tk {vat.toFixed(2)}</p>
                                </div>
                                {selectedTip > 0 && (
                                    <div className="flex justify-between">
                                        <p>Tip</p>
                                        <p>Tk {selectedTip.toFixed(2)}</p>
                                    </div>
                                )}
                            </div>

                            <Separator className="my-4" />

                            <div className="flex justify-between font-bold text-lg">
                                <p>Total</p>
                                <p>Tk {total.toFixed(2)}</p>
                            </div>
                        </Card>
                    </aside>
                </div>
            </div>
        </div>
    );
}

export default function CheckoutPage() {
    return (
        <Suspense fallback={
            <div className="flex items-center justify-center min-h-screen">
                <Loader2 className="h-8 w-8 animate-spin" />
            </div>
        }>
            <CheckoutPageContent />
        </Suspense>
    );
}
