'use client';
//src/app/partner/page.tsx
import React, { useState, useEffect } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import * as z from 'zod';
import { Button } from '../../components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '../../components/ui/card';
import { Form, FormControl, FormField, FormItem, FormLabel, FormMessage, FormDescription } from '../../components/ui/form';
import { Input } from '../../components/ui/input';
import { RadioGroup, RadioGroupItem } from '../../components/ui/radio-group';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '../../components/ui/select';
import { Loader2, Handshake, Upload, CheckCircle2, Clock, ArrowLeft, ArrowRight, Store, FileText, CreditCard, TrendingUp, ShieldCheck, Info } from 'lucide-react';
import Image from 'next/image';
import { Alert, AlertDescription } from '../../components/ui/alert';
import { useToast } from '../../hooks/use-toast';
import { useRouter } from 'next/navigation';
import { getCurrentUser } from '../../lib/auth';
import { uploadData } from '../../lib/storage';


// Business types
const businessTypes = [
  "Restaurant", "Cloud Kitchen", "Cafe", "Bakery", "Sweet Shop",
  "Fast Food", "Fine Dining", "Food Truck"
];

// Step 1: Business Information Schema
const step1Schema = z.object({
  name: z.string().min(2, "Business name must be at least 2 characters"),
  businessType: z.string().min(1, "Please select a business type"),
  phone: z.string().min(11, "Please enter a valid phone number (11 digits)"),
  email: z.string().email("Please enter a valid email address"),
  photo: z.instanceof(File, { message: "Business photo is required" }),
});

// Step 2: Tax & Legal Information Schema
const step2Schema = z.object({
  hasBinVat: z.enum(["yes", "no"], { required_error: "Please select an option" }),
  displayPriceWithVat: z.enum(["yes", "no"]).optional(),
  binVatNumber: z.string().optional(),
});

// Step 3: Banking Information Schema
const step3Schema = z.object({
  accountHolderName: z.string().min(2, "Account holder name is required"),
  accountType: z.enum(["bank", "bkash", "nagad", "rocket"], { required_error: "Please select account type" }),
  accountNumber: z.string().min(5, "Please enter a valid account number"),
  bankName: z.string().optional(),
  branchName: z.string().optional(),
  routingNumber: z.string().optional(),
});

// Step 4: Address & Pricing Schema
const step4Schema = z.object({
  address: z.string().min(10, "Please enter complete billing address"),
  city: z.string().min(2, "City is required"),
  postalCode: z.string().min(4, "Postal code is required"),
  pricingPlan: z.enum(["growth-pro", "growth-plus", "basic"], { required_error: "Please select a pricing plan" }),
});

// Combined schema for all steps
const fullFormSchema = step1Schema.merge(step2Schema).merge(step3Schema).merge(step4Schema);

type FormValues = z.infer<typeof fullFormSchema>;

export default function PartnerRegistrationPage() {
  const { toast } = useToast();
  const router = useRouter();
  const [currentStep, setCurrentStep] = useState(1);
  const [preview, setPreview] = useState<string | null>(null);
  const [formSubmitting, setFormSubmitting] = useState(false);
  const [submissionSuccess, setSubmissionSuccess] = useState(false);
  const [restaurantName, setRestaurantName] = useState('');
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [userId, setUserId] = useState<string | null>(null);
  const [isCheckingAuth, setIsCheckingAuth] = useState(true);

  const totalSteps = 4;
  const progress = (currentStep / totalSteps) * 100;

  useEffect(() => {
    checkAuthStatus();
  }, []);

  const checkAuthStatus = async () => {
    try {
      const user = await getCurrentUser();
      setIsAuthenticated(true);
      setUserId(user.userId);
      console.log('✅ User authenticated:', user.userId);
    } catch (error) {
      setIsAuthenticated(false);
      setUserId(null);
      toast({
        variant: "destructive",
        title: "Authentication Required",
        description: "Please log in to submit a partnership application.",
      });
      setTimeout(() => {
        router.push('/login');
      }, 2000);
    } finally {
      setIsCheckingAuth(false);
    }
  };

  const form = useForm<FormValues>({
    resolver: zodResolver(fullFormSchema),
    mode: 'onChange',
    defaultValues: {
      name: "",
      businessType: "",
      phone: "",
      email: "",
      hasBinVat: undefined,
      displayPriceWithVat: undefined,
      accountHolderName: "",
      accountType: undefined,
      accountNumber: "",
      address: "",
      city: "",
      postalCode: "",
      pricingPlan: undefined,
    },
  });

  const watchHasBinVat = form.watch("hasBinVat");
  const watchAccountType = form.watch("accountType");

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files[0]) {
      const file = e.target.files[0];
      form.setValue('photo', file);
      form.clearErrors('photo');
      const reader = new FileReader();
      reader.onloadend = () => {
        setPreview(reader.result as string);
      };
      reader.readAsDataURL(file);
    }
  };

  const validateCurrentStep = async () => {
    let fieldsToValidate: (keyof FormValues)[] = [];

    switch (currentStep) {
      case 1:
        fieldsToValidate = ['name', 'businessType', 'phone', 'email', 'photo'];
        break;
      case 2:
        fieldsToValidate = ['hasBinVat'];
        if (watchHasBinVat === 'yes') {
          fieldsToValidate.push('displayPriceWithVat', 'binVatNumber');
        }
        break;
      case 3:
        fieldsToValidate = ['accountHolderName', 'accountType', 'accountNumber'];
        if (watchAccountType === 'bank') {
          fieldsToValidate.push('bankName', 'branchName', 'routingNumber');
        }
        break;
      case 4:
        fieldsToValidate = ['address', 'city', 'postalCode', 'pricingPlan'];
        break;
    }

    const result = await form.trigger(fieldsToValidate);
    return result;
  };

  const handleNext = async () => {
    const isValid = await validateCurrentStep();
    if (isValid && currentStep < totalSteps) {
      setCurrentStep(currentStep + 1);
      window.scrollTo({ top: 0, behavior: 'smooth' });
    }
  };

  const handlePrevious = () => {
    if (currentStep > 1) {
      setCurrentStep(currentStep - 1);
      window.scrollTo({ top: 0, behavior: 'smooth' });
    }
  };

  const onSubmit = async (values: FormValues) => {
    if (!isAuthenticated || !userId) {
      toast({
        variant: "destructive",
        title: "Authentication Required",
        description: "Please log in to submit your application.",
      });
      router.push('/login');
      return;
    }

    setFormSubmitting(true);

    try {
      console.log('🚀 Starting form submission...');
      console.log('📋 Form values:', values);

      // Upload restaurant photo to S3
      const photoFile = values.photo;
      const timestamp = Date.now();
      const photoFileName = `${timestamp}-${photoFile.name}`;

      console.log('📤 Uploading photo:', photoFileName);


      // Upload using simple string path
      await uploadData({
        path: `restaurant-photos/${photoFileName}`,
        data: photoFile,
        options: {
          contentType: photoFile.type,
        },
      });

      console.log('✅ Photo uploaded successfully');

      const storedPhotoPath = `restaurant-photos/${photoFileName}`;

      console.log('📝 Storing restaurant data in database...');
      console.log('User ID:', userId);

      // Save restaurant data to database with 'pending' status
      const restaurantData = {
        name: values.name,
        email: values.email,
        phone: values.phone,
        address: values.address,
        photoUrl: storedPhotoPath,
        ownerId: userId,
        status: 'pending',
        businessType: values.businessType,
        hasBinVat: values.hasBinVat,
        binVatNumber: values.binVatNumber || null,
        displayPriceWithVat: values.displayPriceWithVat || null,
        accountHolderName: values.accountHolderName,
        accountType: values.accountType,
        accountNumber: values.accountNumber,
        bankName: values.bankName || null,
        branchName: values.branchName || null,
        routingNumber: values.routingNumber || null,
        city: values.city,
        postalCode: values.postalCode,
        pricingPlan: values.pricingPlan,
      };

      console.log('💾 Restaurant data to save:', restaurantData);


      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000';
      const response = await fetch(`${apiUrl}/api/restaurants`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(restaurantData)
      });

      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.message || 'Failed to create restaurant');
      }

      const restaurant = await response.json();

      if (errors && errors.length > 0) {
        console.error('❌ Database errors:', errors);
        throw new Error(errors[0].message);
      }

      console.log('✅ Restaurant data saved successfully:', restaurant);

      // Store restaurant name for success message
      setRestaurantName(values.name);

      // Show success state
      setSubmissionSuccess(true);

      // Show success toast
      toast({
        title: "Application Submitted!",
        description: "Your restaurant application is now pending approval.",
      });

    } catch (error) {
      console.error("❌ Error submitting application:", error);
      toast({
        variant: "destructive",
        title: "Submission Failed",
        description: error instanceof Error ? error.message : "An unknown error occurred. Please try again.",
      });
    } finally {
      setFormSubmitting(false);
    }
  };

  if (isCheckingAuth) {
    return (
      <div className="container mx-auto py-12 px-4">
        <Card className="max-w-2xl mx-auto">
          <CardContent className="py-12">
            <div className="text-center">
              <Loader2 className="h-12 w-12 animate-spin mx-auto mb-4 text-primary" />
              <p className="text-muted-foreground">Checking authentication...</p>
            </div>
          </CardContent>
        </Card>
      </div>
    );
  }

  if (!isAuthenticated) {
    return (
      <div className="container mx-auto py-12 px-4">
        <Card className="max-w-2xl mx-auto">
          <CardContent className="py-12">
            <div className="text-center">
              <Handshake className="h-12 w-12 mx-auto mb-4 text-muted-foreground" />
              <p className="text-muted-foreground">Redirecting to login...</p>
            </div>
          </CardContent>
        </Card>
      </div>
    );
  }

  if (submissionSuccess) {
    return (
      <div className="container mx-auto py-12 px-4">
        <Card className="max-w-2xl mx-auto">
          <CardContent className="py-12">
            <div className="text-center space-y-6">
              <div className="inline-block bg-green-100 p-4 rounded-full">
                <CheckCircle2 className="h-16 w-16 text-green-600" />
              </div>
              <div className="space-y-2">
                <h2 className="text-3xl font-bold">Application Submitted Successfully!</h2>
                <p className="text-xl text-muted-foreground">Thank you for partnering with Zhigo.</p>
              </div>
              <Card className="bg-amber-50 border-amber-200">
                <CardContent className="pt-6">
                  <div className="flex items-start gap-4">
                    <Clock className="h-6 w-6 text-amber-600 mt-1 flex-shrink-0" />
                    <div className="text-left space-y-2">
                      <h3 className="font-semibold text-lg">Pending Admin Approval</h3>
                      <p className="text-sm text-muted-foreground">
                        Your application for <span className="font-semibold">{restaurantName}</span> is under review.
                      </p>
                      <p className="text-sm text-muted-foreground">
                        We'll notify you via email within 1-2 business days.
                      </p>
                    </div>
                  </div>
                </CardContent>
              </Card>
              <div className="flex flex-col sm:flex-row gap-3 justify-center pt-4">
                <Button
                  onClick={() => router.push('/')}
                  variant="default"
                >
                  Go to Home
                </Button>
                <Button
                  onClick={() => router.push('/restaurants')}
                  variant="outline"
                >
                  Browse Restaurants
                </Button>
              </div>
              <p className="text-sm text-muted-foreground pt-4">
                Questions? Contact us at <a href="mailto:support@zhigo.com" className="text-primary underline">support@zhigo.com</a>
              </p>
            </div>
          </CardContent>
        </Card>
      </div>
    );
  }

  return (
    <div className="container mx-auto py-8 px-4">
      <Card className="max-w-3xl mx-auto">
        <CardHeader className="pb-4">
          <div className="mx-auto text-center mb-2">
            <div className="inline-block bg-primary/10 p-3 rounded-full">
              <Handshake className="h-8 w-8 text-primary" />
            </div>
          </div>
          <CardTitle className="text-center text-2xl sm:text-3xl font-bold">
            Become a Zhigo Partner
          </CardTitle>
          <CardDescription className="text-center">
            Join thousands of restaurants growing their business with us
          </CardDescription>
        </CardHeader>

        {/* Progress Bar */}
        <div className="px-6 pb-6">
          <div className="relative">
            <div className="flex justify-between mb-2">
              <span className="text-sm font-medium text-primary">Step {currentStep} of {totalSteps}</span>
              <span className="text-sm font-medium text-muted-foreground">{Math.round(progress)}%</span>
            </div>
            <div className="w-full bg-gray-200 rounded-full h-2.5">
              <div
                className="bg-primary h-2.5 rounded-full transition-all duration-300 ease-in-out"
                style={{ width: `${progress}%` }}
              />
            </div>
            <div className="flex justify-between mt-3">
              <div className={`flex flex-col items-center ${currentStep >= 1 ? 'text-primary' : 'text-muted-foreground'}`}>
                <Store className="h-5 w-5 mb-1" />
                <span className="text-xs hidden sm:block">Business</span>
              </div>
              <div className={`flex flex-col items-center ${currentStep >= 2 ? 'text-primary' : 'text-muted-foreground'}`}>
                <FileText className="h-5 w-5 mb-1" />
                <span className="text-xs hidden sm:block">Tax Info</span>
              </div>
              <div className={`flex flex-col items-center ${currentStep >= 3 ? 'text-primary' : 'text-muted-foreground'}`}>
                <CreditCard className="h-5 w-5 mb-1" />
                <span className="text-xs hidden sm:block">Banking</span>
              </div>
              <div className={`flex flex-col items-center ${currentStep >= 4 ? 'text-primary' : 'text-muted-foreground'}`}>
                <TrendingUp className="h-5 w-5 mb-1" />
                <span className="text-xs hidden sm:block">Pricing</span>
              </div>
            </div>
          </div>
        </div>

        <CardContent>
          <Form {...form}>
            <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">

              {/* STEP 1: Business Information */}
              {currentStep === 1 && (
                <div className="space-y-6 animate-in fade-in duration-300">
                  <div className="space-y-2">
                    <h3 className="text-xl font-semibold flex items-center gap-2">
                      <Store className="h-5 w-5" />
                      Business Information
                    </h3>
                    <p className="text-sm text-muted-foreground">
                      Let's start with the basics. Tell us about your restaurant.
                    </p>
                  </div>

                  <Alert className="bg-blue-50 border-blue-200">
                    <ShieldCheck className="h-4 w-4 text-blue-600" />
                    <AlertDescription className="text-sm text-blue-900">
                      Your information is secure and will only be used for verification purposes.
                    </AlertDescription>
                  </Alert>

                  <FormField
                    control={form.control}
                    name="photo"
                    render={({ field: { value, onChange, ...fieldProps } }) => (
                      <FormItem>
                        <FormLabel>Restaurant Photo *</FormLabel>
                        <FormDescription>
                          Upload a high-quality photo of your restaurant's exterior or interior
                        </FormDescription>
                        <FormControl>
                          <div className="flex items-center justify-center w-full">
                            <label htmlFor="photo-upload" className="flex flex-col items-center justify-center w-full h-48 border-2 border-dashed rounded-lg cursor-pointer hover:bg-muted transition-colors">
                              {preview ? (
                                <Image src={preview} alt="Business preview" width={200} height={200} className="h-44 w-auto object-contain rounded-md p-1" />
                              ) : (
                                <div className="flex flex-col items-center justify-center pt-5 pb-6">
                                  <Upload className="w-10 h-10 mb-3 text-muted-foreground" />
                                  <p className="mb-2 text-sm text-muted-foreground">
                                    <span className="font-semibold">Click to upload</span> or drag and drop
                                  </p>
                                  <p className="text-xs text-muted-foreground">PNG, JPG up to 10MB</p>
                                </div>
                              )}
                              <Input
                                id="photo-upload"
                                type="file"
                                className="sr-only"
                                onChange={handleFileChange}
                                accept="image/*"
                                {...fieldProps}
                              />
                            </label>
                          </div>
                        </FormControl>
                        <FormMessage />
                      </FormItem>
                    )}
                  />

                  <FormField
                    control={form.control}
                    name="name"
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel>Business Name *</FormLabel>
                        <FormDescription>
                          Use your official registered business name
                        </FormDescription>
                        <FormControl>
                          <Input placeholder="e.g., The Golden Spoon Restaurant" {...field} />
                        </FormControl>
                        <FormMessage />
                      </FormItem>
                    )}
                  />

                  <FormField
                    control={form.control}
                    name="businessType"
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel>Business Type *</FormLabel>
                        <Select onValueChange={field.onChange} value={field.value}>
                          <FormControl>
                            <SelectTrigger>
                              <SelectValue placeholder="Select your business type" />
                            </SelectTrigger>
                          </FormControl>
                          <SelectContent>
                            {businessTypes.map((type) => (
                              <SelectItem key={type} value={type}>{type}</SelectItem>
                            ))}
                          </SelectContent>
                        </Select>
                        <FormMessage />
                      </FormItem>
                    )}
                  />

                  <FormField
                    control={form.control}
                    name="phone"
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel>Business Phone Number *</FormLabel>
                        <FormDescription>
                          Customers will use this number to contact you
                        </FormDescription>
                        <FormControl>
                          <Input placeholder="01712345678" {...field} />
                        </FormControl>
                        <FormMessage />
                      </FormItem>
                    )}
                  />

                  <FormField
                    control={form.control}
                    name="email"
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel>Business Email *</FormLabel>
                        <FormDescription>
                          We'll send important updates to this email
                        </FormDescription>
                        <FormControl>
                          <Input placeholder="contact@restaurant.com" {...field} />
                        </FormControl>
                        <FormMessage />
                      </FormItem>
                    )}
                  />
                </div>
              )}

              {/* STEP 2: Tax & Legal Information */}
              {currentStep === 2 && (
                <div className="space-y-6 animate-in fade-in duration-300">
                  <div className="space-y-2">
                    <h3 className="text-xl font-semibold flex items-center gap-2">
                      <FileText className="h-5 w-5" />
                      Tax & Legal Information
                    </h3>
                    <p className="text-sm text-muted-foreground">
                      Help us understand your tax registration status.
                    </p>
                  </div>

                  <Alert className="bg-green-50 border-green-200">
                    <Info className="h-4 w-4 text-green-600" />
                    <AlertDescription className="text-sm text-green-900">
                      Having a BIN/VAT certificate helps build customer trust and may unlock additional features!
                    </AlertDescription>
                  </Alert>

                  <FormField
                    control={form.control}
                    name="hasBinVat"
                    render={({ field }) => (
                      <FormItem className="space-y-3">
                        <FormLabel>Do you have a BIN/VAT Certificate? *</FormLabel>
                        <FormDescription>
                          This helps customers identify verified businesses
                        </FormDescription>
                        <FormControl>
                          <RadioGroup
                            onValueChange={field.onChange}
                            value={field.value}
                            className="flex flex-col space-y-1"
                          >
                            <FormItem className="flex items-center space-x-3 space-y-0 border rounded-lg p-4 cursor-pointer hover:bg-muted">
                              <FormControl>
                                <RadioGroupItem value="yes" />
                              </FormControl>
                              <div className="flex-1">
                                <FormLabel className="font-normal cursor-pointer">
                                  Yes, I have a BIN/VAT Certificate
                                </FormLabel>
                                <p className="text-xs text-muted-foreground">Verified businesses get priority placement</p>
                              </div>
                            </FormItem>
                            <FormItem className="flex items-center space-x-3 space-y-0 border rounded-lg p-4 cursor-pointer hover:bg-muted">
                              <FormControl>
                                <RadioGroupItem value="no" />
                              </FormControl>
                              <div className="flex-1">
                                <FormLabel className="font-normal cursor-pointer">
                                  No, I don't have one yet
                                </FormLabel>
                                <p className="text-xs text-muted-foreground">You can still partner with us</p>
                              </div>
                            </FormItem>
                          </RadioGroup>
                        </FormControl>
                        <FormMessage />
                      </FormItem>
                    )}
                  />

                  {watchHasBinVat === 'yes' && (
                    <div className="space-y-6 animate-in fade-in duration-300">
                      <FormField
                        control={form.control}
                        name="binVatNumber"
                        render={({ field }) => (
                          <FormItem>
                            <FormLabel>BIN/VAT Certificate Number *</FormLabel>
                            <FormControl>
                              <Input placeholder="Enter your BIN/VAT number" {...field} />
                            </FormControl>
                            <FormMessage />
                          </FormItem>
                        )}
                      />

                      <FormField
                        control={form.control}
                        name="displayPriceWithVat"
                        render={({ field }) => (
                          <FormItem className="space-y-3">
                            <FormLabel>Display Prices Including VAT? *</FormLabel>
                            <FormDescription>
                              Choose how you want menu prices to appear to customers
                            </FormDescription>
                            <FormControl>
                              <RadioGroup
                                onValueChange={field.onChange}
                                value={field.value}
                                className="flex flex-col space-y-1"
                              >
                                <FormItem className="flex items-center space-x-3 space-y-0 border rounded-lg p-4 cursor-pointer hover:bg-muted">
                                  <FormControl>
                                    <RadioGroupItem value="yes" />
                                  </FormControl>
                                  <FormLabel className="font-normal cursor-pointer flex-1">
                                    Yes, include VAT in displayed prices
                                    <p className="text-xs text-muted-foreground mt-1">Customers see final price (e.g., ৳500 with VAT included)</p>
                                  </FormLabel>
                                </FormItem>
                                <FormItem className="flex items-center space-x-3 space-y-0 border rounded-lg p-4 cursor-pointer hover:bg-muted">
                                  <FormControl>
                                    <RadioGroupItem value="no" />
                                  </FormControl>
                                  <FormLabel className="font-normal cursor-pointer flex-1">
                                    No, add VAT at checkout
                                    <p className="text-xs text-muted-foreground mt-1">VAT calculated separately (e.g., ৳500 + VAT)</p>
                                  </FormLabel>
                                </FormItem>
                              </RadioGroup>
                            </FormControl>
                            <FormMessage />
                          </FormItem>
                        )}
                      />
                    </div>
                  )}
                </div>
              )}

              {/* STEP 3: Banking Information */}
              {currentStep === 3 && (
                <div className="space-y-6 animate-in fade-in duration-300">
                  <div className="space-y-2">
                    <h3 className="text-xl font-semibold flex items-center gap-2">
                      <CreditCard className="h-5 w-5" />
                      Banking Information
                    </h3>
                    <p className="text-sm text-muted-foreground">
                      Where should we send your earnings?
                    </p>
                  </div>

                  <Alert className="bg-amber-50 border-amber-200">
                    <Info className="h-4 w-4 text-amber-600" />
                    <AlertDescription className="text-sm text-amber-900">
                      <strong>Important:</strong> You'll need to upload bank statement proof later. Make sure the account holder name matches exactly!
                    </AlertDescription>
                  </Alert>

                  <FormField
                    control={form.control}
                    name="accountHolderName"
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel>Account Holder Name *</FormLabel>
                        <FormDescription>
                          Enter name exactly as shown in bank statements. For business accounts, use the business name (not personal name).
                        </FormDescription>
                        <FormControl>
                          <Input placeholder="Account holder's full name" {...field} />
                        </FormControl>
                        <FormMessage />
                      </FormItem>
                    )}
                  />

                  <FormField
                    control={form.control}
                    name="accountType"
                    render={({ field }) => (
                      <FormItem className="space-y-3">
                        <FormLabel>Account Type *</FormLabel>
                        <FormDescription>
                          Choose your preferred payment method
                        </FormDescription>
                        <FormControl>
                          <RadioGroup
                            onValueChange={field.onChange}
                            value={field.value}
                            className="grid grid-cols-2 gap-3"
                          >
                            <FormItem>
                              <FormControl>
                                <RadioGroupItem value="bank" className="peer sr-only" />
                              </FormControl>
                              <FormLabel className="flex flex-col items-center justify-between rounded-md border-2 border-muted bg-transparent p-4 hover:bg-accent hover:text-accent-foreground peer-data-[state=checked]:border-primary [&:has([data-state=checked])]:border-primary cursor-pointer">
                                <span className="text-sm font-medium">Bank Account</span>
                              </FormLabel>
                            </FormItem>
                            <FormItem>
                              <FormControl>
                                <RadioGroupItem value="bkash" className="peer sr-only" />
                              </FormControl>
                              <FormLabel className="flex flex-col items-center justify-between rounded-md border-2 border-muted bg-transparent p-4 hover:bg-accent hover:text-accent-foreground peer-data-[state=checked]:border-primary [&:has([data-state=checked])]:border-primary cursor-pointer">
                                <span className="text-sm font-medium">bKash</span>
                              </FormLabel>
                            </FormItem>
                            <FormItem>
                              <FormControl>
                                <RadioGroupItem value="nagad" className="peer sr-only" />
                              </FormControl>
                              <FormLabel className="flex flex-col items-center justify-between rounded-md border-2 border-muted bg-transparent p-4 hover:bg-accent hover:text-accent-foreground peer-data-[state=checked]:border-primary [&:has([data-state=checked])]:border-primary cursor-pointer">
                                <span className="text-sm font-medium">Nagad</span>
                              </FormLabel>
                            </FormItem>
                            <FormItem>
                              <FormControl>
                                <RadioGroupItem value="rocket" className="peer sr-only" />
                              </FormControl>
                              <FormLabel className="flex flex-col items-center justify-between rounded-md border-2 border-muted bg-transparent p-4 hover:bg-accent hover:text-accent-foreground peer-data-[state=checked]:border-primary [&:has([data-state=checked])]:border-primary cursor-pointer">
                                <span className="text-sm font-medium">Rocket</span>
                              </FormLabel>
                            </FormItem>
                          </RadioGroup>
                        </FormControl>
                        <FormMessage />
                      </FormItem>
                    )}
                  />

                  {watchAccountType === 'bank' && (
                    <div className="space-y-4 animate-in fade-in duration-300">
                      <FormField
                        control={form.control}
                        name="bankName"
                        render={({ field }) => (
                          <FormItem>
                            <FormLabel>Bank Name *</FormLabel>
                            <FormControl>
                              <Input placeholder="e.g., Dutch Bangla Bank" {...field} />
                            </FormControl>
                            <FormMessage />
                          </FormItem>
                        )}
                      />
                      <FormField
                        control={form.control}
                        name="branchName"
                        render={({ field }) => (
                          <FormItem>
                            <FormLabel>Branch Name *</FormLabel>
                            <FormControl>
                              <Input placeholder="e.g., Gulshan Branch" {...field} />
                            </FormControl>
                            <FormMessage />
                          </FormItem>
                        )}
                      />
                      <FormField
                        control={form.control}
                        name="accountNumber"
                        render={({ field }) => (
                          <FormItem>
                            <FormLabel>Account Number *</FormLabel>
                            <FormControl>
                              <Input placeholder="Enter your bank account number" {...field} />
                            </FormControl>
                            <FormMessage />
                          </FormItem>
                        )}
                      />
                      <FormField
                        control={form.control}
                        name="routingNumber"
                        render={({ field }) => (
                          <FormItem>
                            <FormLabel>Routing Number *</FormLabel>
                            <FormControl>
                              <Input placeholder="9-digit routing number" {...field} />
                            </FormControl>
                            <FormMessage />
                          </FormItem>
                        )}
                      />
                    </div>
                  )}

                  {(watchAccountType === 'bkash' || watchAccountType === 'nagad' || watchAccountType === 'rocket') && (
                    <FormField
                      control={form.control}
                      name="accountNumber"
                      render={({ field }) => (
                        <FormItem>
                          <FormLabel>Mobile Number *</FormLabel>
                          <FormDescription>
                            Enter the {watchAccountType} account mobile number
                          </FormDescription>
                          <FormControl>
                            <Input placeholder="01XXXXXXXXX" {...field} />
                          </FormControl>
                          <FormMessage />
                        </FormItem>
                      )}
                    />
                  )}
                </div>
              )}

              {/* STEP 4: Address & Pricing Plan */}
              {currentStep === 4 && (
                <div className="space-y-6 animate-in fade-in duration-300">
                  <div className="space-y-2">
                    <h3 className="text-xl font-semibold flex items-center gap-2">
                      <TrendingUp className="h-5 w-5" />
                      Address & Pricing Plan
                    </h3>
                    <p className="text-sm text-muted-foreground">
                      Final step! Choose your pricing plan and confirm your address.
                    </p>
                  </div>

                  <Alert className="bg-purple-50 border-purple-200">
                    <ShieldCheck className="h-4 w-4 text-purple-600" />
                    <AlertDescription className="text-sm text-purple-900">
                      🎉 You're almost done! Choose a plan that fits your business goals.
                    </AlertDescription>
                  </Alert>

                  <div className="space-y-4">
                    <h4 className="font-semibold text-lg">Billing Address</h4>

                    <FormField
                      control={form.control}
                      name="address"
                      render={({ field }) => (
                        <FormItem>
                          <FormLabel>Complete Address *</FormLabel>
                          <FormDescription>
                            House/Building, Road, Area
                          </FormDescription>
                          <FormControl>
                            <Input placeholder="123 Main Street, Gulshan-1" {...field} />
                          </FormControl>
                          <FormMessage />
                        </FormItem>
                      )}
                    />

                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                      <FormField
                        control={form.control}
                        name="city"
                        render={({ field }) => (
                          <FormItem>
                            <FormLabel>City *</FormLabel>
                            <FormControl>
                              <Input placeholder="Dhaka" {...field} />
                            </FormControl>
                            <FormMessage />
                          </FormItem>
                        )}
                      />

                      <FormField
                        control={form.control}
                        name="postalCode"
                        render={({ field }) => (
                          <FormItem>
                            <FormLabel>Postal Code *</FormLabel>
                            <FormControl>
                              <Input placeholder="1212" {...field} />
                            </FormControl>
                            <FormMessage />
                          </FormItem>
                        )}
                      />
                    </div>
                  </div>

                  <div className="space-y-4 pt-4">
                    <h4 className="font-semibold text-lg">Choose Your Pricing Plan</h4>
                    <p className="text-sm text-muted-foreground">
                      Select the plan that best fits your business needs. You can upgrade anytime!
                    </p>

                    <FormField
                      control={form.control}
                      name="pricingPlan"
                      render={({ field }) => (
                        <FormItem className="space-y-3">
                          <FormControl>
                            <RadioGroup
                              onValueChange={field.onChange}
                              value={field.value}
                              className="grid grid-cols-1 gap-4"
                            >
                              {/* Growth Pro Plan */}
                              <FormItem>
                                <FormControl>
                                  <RadioGroupItem value="growth-pro" className="peer sr-only" />
                                </FormControl>
                                <FormLabel className="flex flex-col rounded-lg border-2 border-muted p-4 cursor-pointer hover:bg-accent peer-data-[state=checked]:border-primary [&:has([data-state=checked])]:border-primary [&:has([data-state=checked])]:bg-primary/5">
                                  <div className="flex items-start justify-between mb-3">
                                    <div className="flex-1">
                                      <div className="flex items-center gap-2 mb-1">
                                        <h5 className="font-bold text-lg">Growth Pro</h5>
                                        <span className="bg-pink-500 text-white text-xs px-2 py-0.5 rounded-full">RECOMMENDED</span>
                                      </div>
                                      <p className="text-sm text-muted-foreground">Maximum support to scale faster</p>
                                    </div>
                                    <div className="text-right">
                                      <p className="text-2xl font-bold">23%</p>
                                      <p className="text-xs text-muted-foreground">Commission</p>
                                    </div>
                                  </div>
                                  <div className="space-y-2 text-sm">
                                    <div className="flex items-center gap-2">
                                      <CheckCircle2 className="h-4 w-4 text-green-600" />
                                      <span>21% commission for first 60 days</span>
                                    </div>
                                    <div className="flex items-center gap-2">
                                      <CheckCircle2 className="h-4 w-4 text-green-600" />
                                      <span>Featured in "New on Zhigo" carousel (30 days)</span>
                                    </div>
                                    <div className="flex items-center gap-2">
                                      <CheckCircle2 className="h-4 w-4 text-green-600" />
                                      <span>Priority visibility with ads 🚀</span>
                                    </div>
                                    <div className="flex items-center gap-2">
                                      <CheckCircle2 className="h-4 w-4 text-green-600" />
                                      <span>No platform fees for first 3 months</span>
                                    </div>
                                    <div className="border-t pt-2 mt-2">
                                      <p className="text-xs text-muted-foreground">Monthly Fee: 1000 BDT • GoDroid App: 0 BDT</p>
                                      <p className="text-xs text-muted-foreground">Paid Placement (300): 2000 BDT • Self-funded Promo (300): 10%</p>
                                    </div>
                                  </div>
                                </FormLabel>
                              </FormItem>

                              {/* Growth Plus Plan */}
                              <FormItem>
                                <FormControl>
                                  <RadioGroupItem value="growth-plus" className="peer sr-only" />
                                </FormControl>
                                <FormLabel className="flex flex-col rounded-lg border-2 border-muted p-4 cursor-pointer hover:bg-accent peer-data-[state=checked]:border-primary [&:has([data-state=checked])]:border-primary [&:has([data-state=checked])]:bg-primary/5">
                                  <div className="flex items-start justify-between mb-3">
                                    <div className="flex-1">
                                      <h5 className="font-bold text-lg mb-1">Growth Plus</h5>
                                      <p className="text-sm text-muted-foreground">Extra perks to speed up growth</p>
                                    </div>
                                    <div className="text-right">
                                      <p className="text-2xl font-bold">24%</p>
                                      <p className="text-xs text-muted-foreground">Commission</p>
                                    </div>
                                  </div>
                                  <div className="space-y-2 text-sm">
                                    <div className="flex items-center gap-2">
                                      <CheckCircle2 className="h-4 w-4 text-green-600" />
                                      <span>22% commission for first 60 days</span>
                                    </div>
                                    <div className="flex items-center gap-2">
                                      <CheckCircle2 className="h-4 w-4 text-green-600" />
                                      <span>Featured in "New on Zhigo" carousel (30 days)</span>
                                    </div>
                                    <div className="flex items-center gap-2">
                                      <CheckCircle2 className="h-4 w-4 text-green-600" />
                                      <span>No platform fees for first 3 months</span>
                                    </div>
                                    <div className="border-t pt-2 mt-2">
                                      <p className="text-xs text-muted-foreground">Monthly Fee: 1000 BDT • GoDroid App: 0 BDT</p>
                                      <p className="text-xs text-muted-foreground">Self-funded Promo (300): 10%</p>
                                    </div>
                                  </div>
                                </FormLabel>
                              </FormItem>

                              {/* Basic Essentials Plan */}
                              <FormItem>
                                <FormControl>
                                  <RadioGroupItem value="basic" className="peer sr-only" />
                                </FormControl>
                                <FormLabel className="flex flex-col rounded-lg border-2 border-muted p-4 cursor-pointer hover:bg-accent peer-data-[state=checked]:border-primary [&:has([data-state=checked])]:border-primary [&:has([data-state=checked])]:bg-primary/5">
                                  <div className="flex items-start justify-between mb-3">
                                    <div className="flex-1">
                                      <h5 className="font-bold text-lg mb-1">Basic Essentials</h5>
                                      <p className="text-sm text-muted-foreground">All basics to start smoothly</p>
                                    </div>
                                    <div className="text-right">
                                      <p className="text-2xl font-bold">25%</p>
                                      <p className="text-xs text-muted-foreground">Commission</p>
                                    </div>
                                  </div>
                                  <div className="space-y-2 text-sm">
                                    <div className="flex items-center gap-2">
                                      <CheckCircle2 className="h-4 w-4 text-green-600" />
                                      <span>No trial commission ✋</span>
                                    </div>
                                    <div className="flex items-center gap-2">
                                      <CheckCircle2 className="h-4 w-4 text-green-600" />
                                      <span>Featured in "New on Zhigo" (30 days)</span>
                                    </div>
                                    <div className="flex items-center gap-2">
                                      <CheckCircle2 className="h-4 w-4 text-green-600" />
                                      <span>No platform fees for first 3 months</span>
                                    </div>
                                    <div className="border-t pt-2 mt-2">
                                      <p className="text-xs text-muted-foreground">Monthly Fee: 1000 BDT • GoDroid App: 0 BDT</p>
                                    </div>
                                  </div>
                                </FormLabel>
                              </FormItem>
                            </RadioGroup>
                          </FormControl>
                          <FormMessage />
                        </FormItem>
                      )}
                    />
                  </div>

                  <Alert className="bg-green-50 border-green-200">
                    <Info className="h-4 w-4 text-green-600" />
                    <AlertDescription className="text-sm text-green-900">
                      💡 <strong>Pro Tip:</strong> Most successful restaurants choose Growth Pro for faster growth and maximum visibility!
                    </AlertDescription>
                  </Alert>
                </div>
              )}

              {/* Navigation Buttons */}
              <div className="flex gap-4 pt-6">
                {currentStep > 1 && (
                  <Button
                    type="button"
                    variant="outline"
                    onClick={handlePrevious}
                    className="flex-1"
                  >
                    <ArrowLeft className="mr-2 h-4 w-4" />
                    Previous
                  </Button>
                )}

                {currentStep < totalSteps ? (
                  <Button
                    type="button"
                    onClick={handleNext}
                    className="flex-1"
                  >
                    Next
                    <ArrowRight className="ml-2 h-4 w-4" />
                  </Button>
                ) : (
                  <Button
                    type="submit"
                    disabled={formSubmitting}
                    className="flex-1"
                  >
                    {formSubmitting && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
                    Submit Application
                  </Button>
                )}
              </div>

              {/* Help Text */}
              <div className="text-center pt-4">
                <p className="text-sm text-muted-foreground">
                  Need help? Contact us at{' '}
                  <a href="mailto:partner@zhigo.com" className="text-primary underline">
                    partner@zhigo.com
                  </a>
                </p>
              </div>
            </form>
          </Form>
        </CardContent>
      </Card>
    </div>
  );
}