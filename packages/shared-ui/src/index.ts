//packages/shared-ui//src/index.ts
// Export all UI components
export * from './components/ui/button';
export * from './components/ui/card';
export * from './components/ui/input';
export * from './components/ui/label';
export * from './components/ui/dialog';
export * from './components/ui/dropdown-menu';
export * from './components/ui/table';
export * from './components/ui/badge';
export * from './components/ui/avatar';
export * from './components/ui/alert';
export * from './components/ui/tabs';
export * from './components/ui/select';
export * from './components/ui/textarea';
export * from './components/ui/checkbox';
export * from './components/ui/radio-group';
export * from './components/ui/switch';
export * from './components/ui/slider';
export * from './components/ui/progress';
export * from './components/ui/separator';
export * from './components/ui/tooltip';
export * from './components/ui/popover';
export * from './components/ui/sheet';
export * from './components/ui/skeleton';
export * from './components/ui/toast';
export * from './components/ui/toaster';
export * from './components/ui/accordion';
export * from './components/ui/alert-dialog';
export * from './components/ui/calendar';
export * from './components/ui/carousel';
export * from './components/ui/chart';
export * from './components/ui/collapsible';
export * from './components/ui/command';
export * from './components/ui/form';
export * from './components/ui/menubar';
export * from './components/ui/scroll-area';
export * from './components/ui/sidebar';

// Export shared business components
// Using export * to handle both named and default exports automatically
export * from './components/order-card';
export * from './components/FloatingChatbot';
export * from './components/login-dialog';
export * from './components/signup-dialog';
export * from './components/oauth-handler';
export * from './components/ActiveDeliveryTracking';
export * from './components/DeliveryRequestPopup';
export * from './components/add-menu-item-dialog';
export * from './components/edit-menu-item-dialog';
export * from './components/admin-sidebar';
export * from './components/dashboard-sidebar';
export * from './components/rider-sidebar';
export * from './components/header';
export * from './components/header-actions';
export * from './components/client-wrapper';
export * from './components/map';
export * from './components/NotFoundPage';
export * from './components/footer';

// Export Features
export * from './features/admin/AdminOverview';
export * from './features/admin/AdminRestaurantList';
export * from './features/admin/AdminRiderList';

export * from './features/restaurant/AnalyticsDashboard';
export * from './features/restaurant/BranchManagement';
export * from './features/restaurant/BillingSettings';
export * from './features/restaurant/HelpCenter';
export * from './features/restaurant/InvoiceList';
export * from './features/restaurant/MarketingTools';
export * from './features/restaurant/MenuManagement';
export * from './features/restaurant/OrderManager';
export * from './features/restaurant/PartnerOnboarding';
export * from './features/restaurant/QRCodeGenerator';
export * from './features/restaurant/RestaurantDashboard';
export * from './features/restaurant/ReviewManager';

export * from './features/customer/RestaurantListing';
export * from './features/customer/RestaurantDetails';
export * from './features/customer/CheckoutFlow';
export * from './features/customer/UserProfile';
export * from './features/customer/MapBrowser';

export * from './features/rider/RiderDashboard';
export * from './features/rider/RiderOnboarding';
export * from './features/rider/RiderSettings';
export * from './features/rider/CheckRiderStatus';
export * from './features/rider/DeliveryTasks';
export * from './features/rider/EarningsView';

// Export hooks
export * from './hooks/use-mobile';
export * from './hooks/use-toast';
export { useAnalytics } from './hooks/useAnalytics';

// Export utils
export * from './lib/utils';
