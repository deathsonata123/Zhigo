//src/components/order-card.tsx
'use client';

import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "../components/ui/card";
import { Button } from "../components/ui/button";
import { Separator } from "../components/ui/separator";
import { Badge } from "../components/ui/badge";
import { AlertCircle, CheckCircle, CookingPot, ExternalLink, Flame, Truck, User, XCircle } from "lucide-react";

type OrderItem = {
    name: string;
    quantity: number;
    price: number;
}

type Order = {
    id: string;
    customerName: string;
    total: number;
    items: OrderItem[] | string; // Can be array or JSON string
    status: 'incoming' | 'active' | 'completed' | 'cancelled';
    subStatus?: 'Preparing' | 'Out for Delivery';
    time: string;
    cancellationReason?: string;
}

export interface OrderCardProps {
    order: Order;
}

export function OrderCard({ order }: OrderCardProps) {
    // Parse items if it's a JSON string
    let items: OrderItem[] = [];
    if (typeof order.items === 'string') {
        try {
            items = JSON.parse(order.items);
        } catch (e) {
            console.error('Failed to parse items:', e);
        }
    } else {
        items = order.items;
    }

    const getStatusInfo = () => {
        switch(order.status) {
            case 'incoming':
                return { icon: <AlertCircle className="h-5 w-5 text-yellow-500" />, text: 'Incoming' };
            case 'active':
                return { icon: <CookingPot className="h-5 w-5 text-blue-500" />, text: 'Active' };
            case 'completed':
                return { icon: <CheckCircle className="h-5 w-5 text-green-500" />, text: 'Completed' };
            case 'cancelled':
                return { icon: <XCircle className="h-5 w-5 text-red-500" />, text: 'Cancelled' };
        }
    }

    const { icon, text } = getStatusInfo();

    return (
        <Card className="flex flex-col">
            <CardHeader className="pb-3">
                <div className="flex justify-between items-start">
                    <div>
                        <CardTitle className="font-bold text-lg">{order.id}</CardTitle>
                        <CardDescription className="flex items-center gap-2 pt-1">
                            <User className="h-4 w-4" /> {order.customerName}
                        </CardDescription>
                    </div>
                    <div className="text-right">
                         <div className="flex items-center gap-2 text-sm font-medium">
                            {icon}
                            <span>{text}</span>
                        </div>
                        <p className="text-xs text-muted-foreground mt-1">{order.time}</p>
                    </div>
                </div>
            </CardHeader>
            <CardContent className="flex-grow">
                 <Separator />
                <div className="py-4 space-y-2">
                    {items.map((item, index) => (
                        <div key={index} className="flex justify-between text-sm">
                            <p>{item.quantity} x {item.name}</p>
                            <p className="font-medium">Tk {(item.price * item.quantity).toFixed(2)}</p>
                        </div>
                    ))}
                </div>
                <Separator />
                
                {order.subStatus && (
                    <div className="mt-4">
                        <Badge variant={order.subStatus === 'Preparing' ? "secondary" : "default"}>
                            {order.subStatus === 'Preparing' ? 
                                <Flame className="mr-1 h-3 w-3" /> : 
                                <Truck className="mr-1 h-3 w-3" />
                            }
                            {order.subStatus}
                        </Badge>
                    </div>
                )}
                {order.cancellationReason && (
                    <p className="text-sm text-destructive mt-4">Reason: {order.cancellationReason}</p>
                )}
            </CardContent>
            <CardFooter className="flex-col gap-2 bg-muted/50 p-3">
                <div className="flex justify-between w-full items-center">
                    <p className="text-sm text-muted-foreground">Total</p>
                    <p className="font-bold text-lg">Tk {order.total.toFixed(2)}</p>
                </div>
                 {order.status === 'incoming' && (
                    <div className="grid grid-cols-2 gap-2 w-full pt-2">
                        <Button variant="outline">Decline</Button>
                        <Button>Accept</Button>
                    </div>
                )}
                {order.status === 'active' && (
                     <Button variant="outline" className="w-full mt-2">
                        <ExternalLink className="mr-2 h-4 w-4" />
                        View Details
                    </Button>
                )}
            </CardFooter>
        </Card>
    );
}
