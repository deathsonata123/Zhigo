import { SNS } from '@aws-sdk/client-sns';
import { SES } from '@aws-sdk/client-ses';

const sns = new SNS({ region: process.env.AWS_REGION || 'us-east-1' });
const ses = new SES({ region: process.env.AWS_REGION || 'us-east-1' });

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
        await ses.sendEmail({
            Source: process.env.FROM_EMAIL || 'noreply@zhigo.com',
            Destination: {
                ToAddresses: [email],
            },
            Message: {
                Subject: {
                    Data: `🎉 Your Zhigo Restaurant "${name}" has been approved!`,
                },
                Body: {
                    Html: {
                        Data: `
              <!DOCTYPE html>
              <html>
              <head>
                <style>
                  body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
                  .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                  .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
                  .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
                  .button { display: inline-block; padding: 12px 30px; background: #667eea; color: white; text-decoration: none; border-radius: 5px; margin: 20px 0; }
                  .footer { text-align: center; margin-top: 20px; color: #666; font-size: 12px; }
                </style>
              </head>
              <body>
                <div class="container">
                  <div class="header">
                    <h1>🎉 Congratulations!</h1>
                  </div>
                  <div class="content">
                    <h2>Your restaurant "${name}" has been approved!</h2>
                    <p>We're excited to welcome you to the Zhigo platform. Your restaurant is now live and customers can start ordering from you!</p>
                    
                    <h3>Next Steps:</h3>
                    <ul>
                      <li>Log in to your dashboard to manage your menu</li>
                      <li>Set your operating hours</li>
                      <li>Start accepting orders!</li>
                    </ul>

                    <a href="${dashboardUrl}" class="button">Access Your Dashboard</a>

                    <p>If you have any questions, our support team is here to help.</p>
                    
                    <p><strong>Dashboard URL:</strong> <a href="${dashboardUrl}">${dashboardUrl}</a></p>
                  </div>
                  <div class="footer">
                    <p>© 2025 Zhigo. All rights reserved.</p>
                  </div>
                </div>
              </body>
              </html>
            `,
                    },
                    Text: {
                        Data: `Congratulations! Your restaurant "${name}" has been approved and is now live on Zhigo. Log in to your dashboard at ${dashboardUrl} to get started.`,
                    },
                },
            },
        });
        console.log(`✅ Email sent to ${email}`);
    } catch (error) {
        console.error('❌ Email error:', error);
    }

    // Send SMS notification
    if (phone) {
        try {
            await sns.publish({
                PhoneNumber: phone,
                Message: `🎉 Congratulations! Your Zhigo restaurant "${name}" has been approved. Log in to your dashboard at ${dashboardUrl} to start managing your menu and orders.`,
            });
            console.log(`✅ SMS sent to ${phone}`);
        } catch (error) {
            console.error('❌ SMS error:', error);
        }
    }
}

export async function notifyRestaurantRejection(restaurant: Restaurant, reason?: string) {
    const { email, phone, name } = restaurant;

    // Send Email
    try {
        await ses.sendEmail({
            Source: process.env.FROM_EMAIL || 'noreply@zhigo.com',
            Destination: {
                ToAddresses: [email],
            },
            Message: {
                Subject: {
                    Data: `Update on Your Zhigo Restaurant Application`,
                },
                Body: {
                    Html: {
                        Data: `
              <!DOCTYPE html>
              <html>
              <head>
                <style>
                  body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
                  .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                  .header { background: #f56565; color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
                  .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
                  .reason-box { background: #fff; border-left: 4px solid #f56565; padding: 15px; margin: 20px 0; }
                  .footer { text-align: center; margin-top: 20px; color: #666; font-size: 12px; }
                </style>
              </head>
              <body>
                <div class="container">
                  <div class="header">
                    <h1>Restaurant Application Update</h1>
                  </div>
                  <div class="content">
                    <h2>Dear ${name} Team,</h2>
                    <p>Thank you for your interest in joining Zhigo. Unfortunately, your restaurant application was not approved at this time.</p>
                    
                    ${reason ? `
                      <div class="reason-box">
                        <strong>Reason:</strong> ${reason}
                      </div>
                    ` : ''}

                    <p>If you have any questions or would like to discuss this decision, please don't hesitate to contact our support team at ${process.env.ADMIN_EMAIL || 'support@zhigo.com'}.</p>

                    <p>We appreciate your understanding.</p>
                    
                    <p>Best regards,<br>The Zhigo Team</p>
                  </div>
                  <div class="footer">
                    <p>© 2025 Zhigo. All rights reserved.</p>
                  </div>
                </div>
              </body>
              </html>
            `,
                    },
                    Text: {
                        Data: `Your Zhigo restaurant "${name}" application was not approved. ${reason ? `Reason: ${reason}` : ''} Please contact support if you have questions.`,
                    },
                },
            },
        });
        console.log(`✅ Rejection email sent to ${email}`);
    } catch (error) {
        console.error('❌ Email error:', error);
    }

    // Send SMS
    if (phone) {
        try {
            await sns.publish({
                PhoneNumber: phone,
                Message: `Your Zhigo restaurant "${name}" application was not approved. Please check your email for details or contact support.`,
            });
            console.log(`✅ Rejection SMS sent to ${phone}`);
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
        await ses.sendEmail({
            Source: process.env.FROM_EMAIL || 'noreply@zhigo.com',
            Destination: {
                ToAddresses: [adminEmail],
            },
            Message: {
                Subject: {
                    Data: `🔔 New Restaurant Application: ${restaurant.name}`,
                },
                Body: {
                    Html: {
                        Data: `
              <h2>New Restaurant Application Received</h2>
              <p><strong>Restaurant Name:</strong> ${restaurant.name}</p>
              <p><strong>Email:</strong> ${restaurant.email}</p>
              <p><strong>Phone:</strong> ${restaurant.phone || 'N/A'}</p>
              <p><strong>Address:</strong> ${restaurant.address}</p>
              <br>
              <p><a href="${adminDashboardUrl}/dashboard/restaurants">Review Application</a></p>
            `,
                    },
                },
            },
        });
        console.log(`✅ Admin notification sent`);
    } catch (error) {
        console.error('❌ Admin notification error:', error);
    }
}
