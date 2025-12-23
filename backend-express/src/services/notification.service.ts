// import { SNS } from '@aws-sdk/client-sns';
// import { SES } from '@aws-sdk/client-ses';

// const sns = new SNS({ region: process.env.AWS_REGION || 'us-east-1' });
// const ses = new SES({ region: process.env.AWS_REGION || 'us-east-1' });

interface Restaurant {
  id: string;
  name: string;
  email: string;
  phone?: string;
  ownerId: string;
  address: string;
}

export async function notifyRestaurantApproval(restaurant: Restaurant) {
  const { email, phone, name } = restaurant;
  const dashboardUrl = process.env.RESTAURANT_DASHBOARD_URL || 'http://localhost:3002';

  // Send Email notification
  try {
    console.log(`[Notification Service] Email would be sent to ${email} (AWS SES disabled)`);
    /*
    await ses.sendEmail({
        // ... existing code
    });
    */
    console.log(`✅ Email notification logged for ${email}`);
  } catch (error) {
    console.error('❌ Email error:', error);
  }

  // Send SMS notification
  if (phone) {
    try {
      console.log(`[Notification Service] SMS would be sent to ${phone} (AWS SNS disabled)`);
      /*
      await sns.publish({
          PhoneNumber: phone,
          Message: `🎉 Congratulations! Your Zhigo restaurant "${name}" has been approved. Log in to your dashboard at ${dashboardUrl} to start managing your menu and orders.`,
      });
      */
      console.log(`✅ SMS notification logged for ${phone}`);
    } catch (error) {
      console.error('❌ SMS error:', error);
    }
  }
}

export async function notifyRestaurantRejection(restaurant: Restaurant, reason?: string) {
  const { email, phone, name } = restaurant;

  // Send Email
  try {
    console.log(`[Notification Service] Rejection email would be sent to ${email} (AWS disabled)`);
    /*
    await ses.sendEmail({
        // ...
    });
    */
    console.log(`✅ Rejection email logged for ${email}`);
  } catch (error) {
    console.error('❌ Email error:', error);
  }

  // Send SMS
  if (phone) {
    try {
      console.log(`[Notification Service] Rejection SMS would be sent to ${phone} (AWS disabled)`);
      /*
      await sns.publish({
          PhoneNumber: phone,
          Message: `Your Zhigo restaurant "${name}" application was not approved. Please check your email for details or contact support.`,
      });
      */
      console.log(`✅ Rejection SMS logged for ${phone}`);
    } catch (error) {
      console.error('❌ SMS error:', error);
    }
  }
}

// Notify new restaurant submission to admin
export async function notifyAdminNewRestaurant(restaurant: Restaurant) {
  const adminEmail = process.env.ADMIN_EMAIL || 'admin@zhigo.com';
  const adminDashboardUrl = process.env.ADMIN_DASHBOARD_URL || 'http://localhost:3001';

  try {
    console.log(`[Notification Service] Admin notification would be sent to ${adminEmail} (AWS disabled)`);
    /*
    await ses.sendEmail({
        // ...
    });
    */
    console.log(`✅ Admin notification logged`);
  } catch (error) {
    console.error('❌ Admin notification error:', error);
  }
}
