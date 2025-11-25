# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

Spree::Core::Engine.load_seed if defined?(Spree::Core)

if ENV['ADMIN_EMAIL'].present? && ENV['ADMIN_PASSWORD'].present?
  admin_email = ENV['ADMIN_EMAIL']
  admin_password = ENV['ADMIN_PASSWORD']
  
  admin_user = Spree::AdminUser.find_or_initialize_by(email: admin_email)
  
  if admin_user.new_record?
    admin_user.password = admin_password
    admin_user.password_confirmation = admin_password
    
    if admin_user.save
      puts "Admin user created successfully with email: #{admin_email}"
      
      admin_role = Spree::Role.find_or_create_by!(name: 'admin')
      
      unless Spree::RoleUser.exists?(role_id: admin_role.id, user_id: admin_user.id, user_type: 'Spree::AdminUser')
        Spree::RoleUser.create!(
          role_id: admin_role.id,
          user_id: admin_user.id,
          user_type: 'Spree::AdminUser'
        )
        puts "Admin role assigned to user"
      else
        puts "Admin role already assigned"
      end
    else
      puts "Failed to create admin user: #{admin_user.errors.full_messages.join(', ')}"
    end
  else
    admin_user.password = admin_password
    admin_user.password_confirmation = admin_password
    
    if admin_user.save
      puts "Admin user password updated for email: #{admin_email}"
      
      admin_role = Spree::Role.find_or_create_by!(name: 'admin')
      
      unless Spree::RoleUser.exists?(role_id: admin_role.id, user_id: admin_user.id, user_type: 'Spree::AdminUser')
        Spree::RoleUser.create!(
          role_id: admin_role.id,
          user_id: admin_user.id,
          user_type: 'Spree::AdminUser'
        )
        puts "Admin role assigned to user"
      end
    else
      puts "Failed to update admin user: #{admin_user.errors.full_messages.join(', ')}"
    end
  end
end
