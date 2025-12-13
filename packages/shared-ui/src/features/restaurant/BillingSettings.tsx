
import { Card, CardContent, CardDescription, CardHeader, CardTitle, CardFooter } from "../../components/ui/card";
import { Button } from "../../components/ui/button";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "../../components/ui/table";
import { Badge } from "../../components/ui/badge";
import { Download, ExternalLink, CircleDollarSign, AlertTriangle } from "lucide-react";

const invoices = [
    { id: 'INV-2024-001', month: 'July 2024', amount: '$4,445.92', status: 'Paid' },
    { id: 'INV-2024-002', month: 'June 2024', amount: '$4,123.50', status: 'Paid' },
    { id: 'INV-2024-003', month: 'May 2024', amount: '$4,876.10', status: 'Paid' },
];

export default function BillingPage() {
    return (
        <div className="space-y-8">
            <header>
                <h1 className="text-4xl font-bold font-headline tracking-tight">Billing & Payouts</h1>
                <p className="text-muted-foreground mt-2 text-lg">Manage your financial details and view your earnings.</p>
            </header>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                <div className="lg:col-span-2">
                    <Card>
                        <CardHeader>
                            <CardTitle>Payout Summary</CardTitle>
                            <CardDescription>Breakdown of your earnings for the current period (July 2024).</CardDescription>
                        </CardHeader>
                        <CardContent className="space-y-4">
                            <div className="flex justify-between items-baseline p-4 bg-muted/50 rounded-lg">
                                <span className="text-muted-foreground">Total Earnings</span>
                                <span className="text-2xl font-bold flex items-center"><CircleDollarSign className="h-5 w-5 mr-1" />5,230.50</span>
                            </div>
                            <div className="flex justify-between items-baseline p-4 bg-muted/50 rounded-lg">
                                <span className="text-muted-foreground">Commission & Fees</span>
                                <span className="text-lg font-medium text-red-500 flex items-center">- <CircleDollarSign className="h-4 w-4 mr-1" />784.58</span>
                            </div>
                            <div className="flex justify-between items-baseline pt-4 border-t mt-4">
                                <span className="font-semibold text-lg">Net Payout</span>
                                <span className="text-3xl font-bold text-green-600 flex items-center"><CircleDollarSign className="h-6 w-6 mr-1" />4,445.92</span>
                            </div>
                        </CardContent>
                        <CardFooter>
                            <Button variant="outline">
                                <ExternalLink className="mr-2" /> View Detailed Report
                            </Button>
                        </CardFooter>
                    </Card>
                </div>

                <div className="lg:col-span-1 space-y-6">
                    <Card>
                        <CardHeader>
                            <CardTitle>Payment Status</CardTitle>
                        </CardHeader>
                        <CardContent>
                            <div className="bg-green-100 text-green-800 p-4 rounded-md">
                                <h4 className="font-semibold">Payout Sent!</h4>
                                <p className="text-sm">Your payout of $4,445.92 for July was sent on August 5, 2024.</p>
                            </div>
                        </CardContent>
                    </Card>
                    <Card>
                        <CardHeader>
                             <CardTitle>Tax & VAT Details</CardTitle>
                        </CardHeader>
                         <CardContent>
                            <p className="text-sm text-muted-foreground">Your tax documents for the year will be available here.</p>
                             <Button variant="secondary" className="w-full mt-4" disabled>Download 2023 Forms</Button>
                        </CardContent>
                    </Card>
                </div>
            </div>

            <Card>
                <CardHeader>
                    <CardTitle>Invoice History</CardTitle>
                    <CardDescription>Download your past monthly invoices.</CardDescription>
                </CardHeader>
                <CardContent>
                    <Table>
                        <TableHeader>
                            <TableRow>
                                <TableHead>Invoice ID</TableHead>
                                <TableHead>Month</TableHead>
                                <TableHead>Amount</TableHead>
                                <TableHead>Status</TableHead>
                                <TableHead className="text-right">Actions</TableHead>
                            </TableRow>
                        </TableHeader>
                        <TableBody>
                            {invoices.map((invoice) => (
                                <TableRow key={invoice.id}>
                                    <TableCell className="font-medium">{invoice.id}</TableCell>
                                    <TableCell>{invoice.month}</TableCell>
                                    <TableCell>{invoice.amount}</TableCell>
                                    <TableCell>
                                        <Badge variant={invoice.status === 'Paid' ? 'default' : 'secondary'} className="bg-green-600 hover:bg-green-700">{invoice.status}</Badge>
                                    </TableCell>
                                    <TableCell className="text-right">
                                        <Button variant="outline" size="sm">
                                            <Download className="mr-2" /> Download
                                        </Button>
                                    </TableCell>
                                </TableRow>
                            ))}
                        </TableBody>
                    </Table>
                </CardContent>
            </Card>

        </div>
    );
}
