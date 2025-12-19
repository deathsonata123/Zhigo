
'use client';
import { Button } from '../../components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '../../components/ui/card';
import { Loader2, Printer } from 'lucide-react';
import QRCode from 'react-qr-code';
import { useRef, useState, useEffect } from 'react';

export default function QrCodePage() {
    const qrCodeRef = useRef<HTMLDivElement>(null);
    const [restaurantUrl, setRestaurantUrl] = useState('');
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        // In a real app, you'd fetch the user's restaurant ID
        const mockRestaurantId = '12345';
        setRestaurantUrl(`${window.location.origin}/restaurants/${mockRestaurantId}`);
        setLoading(false);
    }, []);
    
    const handlePrint = () => {
        const svg = qrCodeRef.current?.querySelector('svg');
        if (svg) {
            const svgData = new XMLSerializer().serializeToString(svg);
            const printWindow = window.open('', '', 'height=600,width=800');
            printWindow?.document.write('<html><head><title>Print QR Code</title>');
            printWindow?.document.write('<style>@media print { body { margin: 0; } }</style>');
            printWindow?.document.write('</head><body style="text-align:center; padding-top: 50px;">');
            printWindow?.document.write(svgData);
            printWindow?.document.write('</body></html>');
            printWindow?.document.close();
            printWindow?.focus();
            printWindow?.print();
        }
    };

    if (loading) {
        return (
            <div className="flex h-full w-full items-center justify-center">
                <Loader2 className="h-8 w-8 animate-spin text-primary" />
            </div>
        );
    }

    return (
        <div>
            <div className="flex justify-between items-center mb-8">
                 <div>
                    <h1 className="text-4xl font-bold font-headline">Your Restaurant QR Code</h1>
                    <p className="text-muted-foreground mt-2 text-lg">
                        Customers can scan this code to view your menu instantly.
                    </p>
                </div>
                 <Button onClick={handlePrint}>
                    <Printer className="mr-2 h-4 w-4" />
                    Print
                </Button>
            </div>
           
            <Card className="max-w-md mx-auto">
                <CardHeader>
                    <CardTitle className="text-center font-headline">Scan to View Menu</CardTitle>
                    <CardDescription className="text-center">
                        Point your phone's camera at this code.
                    </CardDescription>
                </CardHeader>
                <CardContent>
                    <div ref={qrCodeRef} className="p-4 bg-white rounded-lg flex justify-center">
                        <QRCode
                            value={restaurantUrl}
                            size={256}
                            viewBox={`0 0 256 256`}
                        />
                    </div>
                </CardContent>
            </Card>
        </div>
    )
}

    
