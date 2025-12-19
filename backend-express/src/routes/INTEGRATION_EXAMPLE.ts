import { CognitoIdentityProviderClient, AdminAddUserToGroupCommand } from '@aws-sdk/client-cognito-identity-provider';
import { notifyRestaurantApproval, notifyRestaurantRejection } from '../services/notification.service';

const cognitoClient = new CognitoIdentityProviderClient({
    region: process.env.AWS_REGION || 'us-east-1'
});

// Add this to your existing restaurant routes file
// This shows the updated PUT endpoint for approving/rejecting restaurants

/*
Example integration in your routes file:

router.put('/:id', async (req, res) => {
  const { id } = req.params;
  const { status, rejectionReason } = req.body;

  try {
    // Update restaurant status in database
    const restaurant = await prisma.restaurant.update({
      where: { id },
      data: { 
        status,
        updatedAt: new Date()
      },
    });

    // If approved, add owner to RestaurantOwner Cognito group
    if (status === 'approved') {
      try {
        const command = new AdminAddUserToGroupCommand({
          UserPoolId: process.env.COGNITO_USER_POOL_ID!,
          Username: restaurant.ownerId,
          GroupName: 'RestaurantOwner',
        });
        
        await cognitoClient.send(command);
        console.log(`✅ Added ${restaurant.ownerId} to RestaurantOwner group`);

        // Create user role record
        await prisma.userRole.create({
          data: {
            userId: restaurant.ownerId,
            role: 'restaurant_owner',
            resourceId: restaurant.id,
          }
        });

      } catch (error) {
        console.error('❌ Error adding to Cognito group:', error);
        // Continue even if Cognito fails - don't block approval
      }

      // Send approval notifications (email + SMS)
      await notifyRestaurantApproval(restaurant);
      
    } else if (status === 'rejected') {
      // Send rejection notifications
      await notifyRestaurantRejection(restaurant, rejectionReason);
    }

    res.json(restaurant);
  } catch (error) {
    console.error('Error updating restaurant:', error);
    res.status(500).json({ error: 'Failed to update restaurant' });
  }
});

// Also add notification when restaurant is created:
router.post('/', async (req, res) => {
  try {
    const restaurant = await prisma.restaurant.create({
      data: {
        ...req.body,
        status: 'pending'
      }
    });

    // Notify admin of new restaurant application
    await notifyAdminNewRestaurant(restaurant);

    res.status(201).json(restaurant);
  } catch (error) {
    console.error('Error creating restaurant:', error);
    res.status(500).json({ error: 'Failed to create restaurant' });
  }
});
*/

export { cognitoClient };
