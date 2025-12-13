import type { AnalyticsData } from '../../shared-types/src/models';

export const exportAnalyticsToCSV = (analytics: AnalyticsData, filename: string = 'analytics-export.csv') => {
  // Sales Data CSV
  const salesCSV = generateSalesCSV(analytics);
  downloadCSV(salesCSV, `${filename}-sales.csv`);
  
  // Best Sellers CSV
  const bestSellersCSV = generateBestSellersCSV(analytics);
  downloadCSV(bestSellersCSV, `${filename}-best-sellers.csv`);
  
  // Busy Hours CSV
  const busyHoursCSV = generateBusyHoursCSV(analytics);
  downloadCSV(busyHoursCSV, `${filename}-busy-hours.csv`);
  
  // Cancellations CSV
  const cancellationsCSV = generateCancellationsCSV(analytics);
  downloadCSV(cancellationsCSV, `${filename}-cancellations.csv`);
  
  // Feedback CSV
  const feedbackCSV = generateFeedbackCSV(analytics);
  downloadCSV(feedbackCSV, `${filename}-feedback.csv`);
};

const generateSalesCSV = (analytics: AnalyticsData): string => {
  const headers = 'Date,Sales,Orders\n';
  const rows = (analytics.salesData || []).map((item: any) => 
    `${item.date},${item.sales},${item.orders}`
  ).join('\n');
  return headers + rows;
};

const generateBestSellersCSV = (analytics: AnalyticsData): string => {
  const headers = 'Name,Quantity,Revenue\n';
  // FIX: Uses item.quantity to match model
  const rows = (analytics.bestSellers || []).map((item: any) => 
    `${item.name},${item.quantity},${item.revenue}`
  ).join('\n');
  return headers + rows;
};

const generateBusyHoursCSV = (analytics: AnalyticsData): string => {
  const headers = 'Hour,Count\n';
  // FIX: Uses item.count to match model
  const rows = (analytics.busyHoursData || []).map((item: any) => 
    `${item.hour},${item.count}`
  ).join('\n');
  return headers + rows;
};

const generateCancellationsCSV = (analytics: AnalyticsData): string => {
  const headers = 'Reason,Count\n';
  const rows = (analytics.cancellationData || []).map((item: any) => 
    `${item.name},${item.value}`
  ).join('\n');
  return headers + rows;
};

const generateFeedbackCSV = (analytics: AnalyticsData): string => {
  const headers = 'User,Rating,Comment,Date\n';
  const rows = (analytics.feedback || []).map((item: any) => 
    `${item.userName},${item.rating},"${item.comment.replace(/"/g, '""')}",${item.createdAt}`
  ).join('\n');
  return headers + rows;
};

const downloadCSV = (csvContent: string, filename: string) => {
  const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
  const link = document.createElement('a');
  const url = URL.createObjectURL(blob);
  
  link.setAttribute('href', url);
  link.setAttribute('download', filename);
  link.style.visibility = 'hidden';
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
};