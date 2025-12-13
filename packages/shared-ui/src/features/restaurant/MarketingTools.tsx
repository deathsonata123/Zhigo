
import { Button } from "../../components/ui/button";
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "../../components/ui/card";
import { Input } from "../../components/ui/input";
import { Label } from "../../components/ui/label";
import { Switch } from "../../components/ui/switch";
import { Tag, Zap, PlusCircle, TrendingUp, Percent } from "lucide-react";

const availableCampaigns = [
    { name: "Free Delivery Bonanza", description: "Attract more customers by offering free delivery on all orders.", cost: "5% commission on campaign orders" },
    { name: "20% Off Weekend Special", description: "Boost your weekend sales with a flat 20% discount.", cost: "Funded by you" },
]

export default function MarketingPage() {
    return (
        <div className="space-y-8">
            <header>
                <h1 className="text-4xl font-bold font-headline tracking-tight">Marketing & Promotions</h1>
                <p className="text-muted-foreground mt-2 text-lg">Boost your sales by running targeted campaigns and offers.</p>
            </header>

            <Card>
                <CardHeader>
                    <CardTitle className="flex items-center"><Zap className="mr-2 text-primary" /> Join a Campaign</CardTitle>
                    <CardDescription>Participate in platform-wide campaigns to increase your visibility and orders.</CardDescription>
                </CardHeader>
                <CardContent className="grid grid-cols-1 md:grid-cols-2 gap-6">
                    {availableCampaigns.map((campaign) => (
                        <Card key={campaign.name} className="bg-muted/40">
                            <CardHeader>
                                <CardTitle className="text-lg">{campaign.name}</CardTitle>
                                <CardDescription>{campaign.description}</CardDescription>
                            </CardHeader>
                            <CardFooter className="flex justify-between items-center">
                                <span className="text-xs text-muted-foreground">{campaign.cost}</span>
                                <Button>Join Now</Button>
                            </CardFooter>
                        </Card>
                    ))}
                </CardContent>
            </Card>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                <div className="lg:col-span-2">
                     <Card>
                        <CardHeader>
                            <CardTitle className="flex items-center"><PlusCircle className="mr-2 text-primary" /> Create Your Own Promotion</CardTitle>
                            <CardDescription>Design a custom discount to meet your specific business goals.</CardDescription>
                        </CardHeader>
                        <CardContent className="space-y-6">
                            <div className="space-y-2">
                                <Label htmlFor="promo-name">Promotion Name</Label>
                                <Input id="promo-name" placeholder="e.g., Lunch Deal" />
                            </div>
                            <div className="grid grid-cols-2 gap-4">
                                <div className="space-y-2">
                                     <Label htmlFor="discount-type">Discount Type</Label>
                                     <Input id="discount-type" placeholder="Percentage / Fixed Amount" />
                                </div>
                                <div className="space-y-2">
                                     <Label htmlFor="discount-value">Value</Label>
                                     <Input id="discount-value" type="number" placeholder="e.g., 15 or 100" />
                                </div>
                            </div>
                             <div className="space-y-2">
                                <Label htmlFor="min-order">Minimum Order Value (Optional)</Label>
                                <Input id="min-order" type="number" placeholder="500" />
                            </div>
                            <div className="flex items-center justify-between rounded-lg border p-4">
                                <div className="space-y-0.5">
                                    <Label htmlFor="promo-active" className="font-medium">Activate Promotion</Label>
                                    <p className="text-xs text-muted-foreground">Make this promotion visible to customers.</p>
                                </div>
                                <Switch id="promo-active" />
                            </div>
                        </CardContent>
                        <CardFooter>
                            <Button>Create Promotion</Button>
                        </CardFooter>
                    </Card>
                </div>

                <div className="lg:col-span-1">
                    <Card>
                        <CardHeader>
                             <CardTitle className="flex items-center"><TrendingUp className="mr-2 text-primary" /> Performance</CardTitle>
                             <CardDescription>See how your campaigns are doing.</CardDescription>
                        </CardHeader>
                        <CardContent className="space-y-4">
                           <div className="flex justify-between items-baseline p-3 bg-muted/50 rounded-lg">
                                <span className="text-sm">Total Orders from Promotions</span>
                                <span className="font-bold text-lg">124</span>
                           </div>
                             <div className="flex justify-between items-baseline p-3 bg-muted/50 rounded-lg">
                                <span className="text-sm">Total Sales from Promotions</span>
                                <span className="font-bold text-lg">$2,480.00</span>
                           </div>
                            <Button variant="outline" className="w-full">View Detailed Report</Button>
                        </CardContent>
                    </Card>
                </div>
            </div>
        </div>
    )
}
