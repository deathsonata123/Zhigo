import { SESClient, SendEmailCommand } from '@aws-sdk/client-ses';
import { SNSClient, PublishCommand } from '@aws-sdk/client-sns';

// AWS clients - uses credentials from environment or IAM role
const sesClient = new SESClient({
  region: process.env.AWS_REGION || 'ap-southeast-1'
});

const snsClient = new SNSClient({
  region: process.env.AWS_REGION || 'ap-southeast-1'
});

interface Restaurant {
  id: string;
  name: string;
  email: string;
  phone?: string;
  owner_id?: string;
  ownerId?: string;
  address: string;
}

// Send approval email via AWS SES
export async function sendApprovalEmail(restaurant: Restaurant): Promise<boolean> {
  const dashboardUrl = process.env.RESTAURANT_DASHBOARD_URL || 'http://localhost:3002/dashboard';
  const senderEmail = process.env.SES_SENDER_EMAIL || 'noreply@zhigo.com';

  const htmlBody = `
    <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
      <div style="background: linear-gradient(135deg, #00D4FF, #00B4D8); padding: 30px; border-radius: 10px 10px 0 0; text-align: center;">
        <h1 style="color: white; margin: 0;">🎉 Congratulations!</h1>
      </div>
      
      <div style="background: #f8f9fa; padding: 30px; border-radius: 0 0 10px 10px;">
        <p style="font-size: 18px; color: #333;">
          Great news! Your restaurant <strong>"${restaurant.name}"</strong> has been approved on Zhigo!
        </p>
        
        <p style="color: #666;">
          You can now access your restaurant dashboard to:
        </p>
        
        <ul style="color: #666;">
          <li>Manage your menu items</li>
          <li>Receive and process orders</li>
          <li>Track earnings and analytics</li>
          <li>Update your restaurant profile</li>
        </ul>
        
        <div style="text-align: center; margin: 30px 0;">
          <a href="${dashboardUrl}" 
             style="background: #00D4FF; color: white; padding: 15px 40px; text-decoration: none; border-radius: 5px; font-weight: bold; display: inline-block;">
            Go to Dashboard
          </a>
        </div>
        
        <p style="color: #999; font-size: 12px; text-align: center;">
          If you have any questions, contact us at support@zhigo.com
        </p>
      </div>
    </div>
  `;

  try {
    // Check if SES is configured
    if (!process.env.SES_SENDER_EMAIL) {
      console.log(`📧 [MOCK - SES not configured] Approval email to ${restaurant.email}:`);
      console.log(`   Subject: 🎉 Your Zhigo Restaurant "${restaurant.name}" is Approved!`);
      console.log(`   Dashboard: ${dashboardUrl}`);
      return true;
    }

    const command = new SendEmailCommand({
      Source: senderEmail,
      Destination: {
        ToAddresses: [restaurant.email],
      },
      Message: {
        Subject: {
          Data: `🎉 Your Zhigo Restaurant "${restaurant.name}" is Approved!`,
          Charset: 'UTF-8',
        },
        Body: {
          Html: {
            Data: htmlBody,
            Charset: 'UTF-8',
          },
          Text: {
            Data: `Congratulations! Your restaurant "${restaurant.name}" has been approved on Zhigo! Visit your dashboard at ${dashboardUrl} to start managing your restaurant.`,
            Charset: 'UTF-8',
          },
        },
      },
    });

    await sesClient.send(command);
    console.log(`✅ Approval email sent to ${restaurant.email} via AWS SES`);
    return true;
  } catch (error: any) {
    console.error('❌ Failed to send approval email via SES:', error.message);
    // Log mock email instead
    console.log(`📧 [FALLBACK] Approval email would be sent to ${restaurant.email}`);
    return false;
  }
}

// Send rejection email via AWS SES
export async function sendRejectionEmail(restaurant: Restaurant, reason?: string): Promise<boolean> {
  const senderEmail = process.env.SES_SENDER_EMAIL || 'noreply@zhigo.com';

  const htmlBody = `
    <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
      <div style="background: #6c757d; padding: 30px; border-radius: 10px 10px 0 0; text-align: center;">
        <h1 style="color: white; margin: 0;">Application Update</h1>
      </div>
      
      <div style="background: #f8f9fa; padding: 30px; border-radius: 0 0 10px 10px;">
        <p style="font-size: 18px; color: #333;">
          We've reviewed your application for <strong>"${restaurant.name}"</strong>.
        </p>
        
        <p style="color: #666;">
          Unfortunately, we're unable to approve your application at this time.
          ${reason ? `<br><br><strong>Reason:</strong> ${reason}` : ''}
        </p>
        
        <p style="color: #666;">
          Please review your submission and feel free to apply again after addressing any issues.
        </p>
        
        <p style="color: #999; font-size: 12px; text-align: center; margin-top: 30px;">
          If you have questions, contact us at support@zhigo.com
        </p>
      </div>
    </div>
  `;

  try {
    if (!process.env.SES_SENDER_EMAIL) {
      console.log(`📧 [MOCK] Rejection email to ${restaurant.email}`);
      return true;
    }

    const command = new SendEmailCommand({
      Source: senderEmail,
      Destination: {
        ToAddresses: [restaurant.email],
      },
      Message: {
        Subject: {
          Data: `Update on Your Zhigo Restaurant Application`,
          Charset: 'UTF-8',
        },
        Body: {
          Html: { Data: htmlBody, Charset: 'UTF-8' },
          Text: { Data: `We've reviewed your application for "${restaurant.name}". Unfortunately, we're unable to approve your application at this time. ${reason || ''}`, Charset: 'UTF-8' },
        },
      },
    });

    await sesClient.send(command);
    console.log(`✅ Rejection email sent to ${restaurant.email} via AWS SES`);
    return true;
  } catch (error: any) {
    console.error('❌ Failed to send rejection email:', error.message);
    return false;
  }
}

// Send SMS via AWS SNS
export async function sendApprovalSMS(phone: string, restaurantName: string): Promise<boolean> {
  const dashboardUrl = process.env.RESTAURANT_DASHBOARD_URL || 'http://localhost:3002';
  const message = `🎉 Congratulations! Your Zhigo restaurant "${restaurantName}" is approved! Visit ${dashboardUrl} to manage your restaurant.`;

  try {
    // Format phone number for international format if needed
    let formattedPhone = phone;
    if (!phone.startsWith('+')) {
      // Assume Bangladesh (+880) if no country code
      formattedPhone = phone.startsWith('0') ? '+88' + phone : '+880' + phone;
    }

    // Check if SNS is configured to send SMS
    if (!process.env.AWS_REGION) {
      console.log(`📱 [MOCK] SMS to ${formattedPhone}:`);
      console.log(`   ${message}`);
      return true;
    }

    const command = new PublishCommand({
      PhoneNumber: formattedPhone,
      Message: message,
      MessageAttributes: {
        'AWS.SNS.SMS.SenderID': {
          DataType: 'String',
          StringValue: 'Zhigo',
        },
        'AWS.SNS.SMS.SMSType': {
          DataType: 'String',
          StringValue: 'Transactional',
        },
      },
    });

    await snsClient.send(command);
    console.log(`✅ Approval SMS sent to ${formattedPhone} via AWS SNS`);
    return true;
  } catch (error: any) {
    console.error('❌ Failed to send SMS via SNS:', error.message);
    console.log(`📱 [FALLBACK] SMS would be sent to ${phone}: ${message}`);
    return false;
  }
}

// Combined notification function
export async function notifyRestaurantApproval(restaurant: Restaurant): Promise<void> {
  console.log(`\n📤 Sending approval notifications for: ${restaurant.name}`);

  // Send email
  await sendApprovalEmail(restaurant);

  // Send SMS if phone available
  if (restaurant.phone) {
    await sendApprovalSMS(restaurant.phone, restaurant.name);
  }

  console.log(`✅ All approval notifications processed\n`);
}

export async function notifyRestaurantRejection(restaurant: Restaurant, reason?: string): Promise<void> {
  console.log(`\n📤 Sending rejection notifications for: ${restaurant.name}`);

  await sendRejectionEmail(restaurant, reason);

  console.log(`✅ Rejection notification sent\n`);
}
