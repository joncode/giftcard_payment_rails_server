class AddInitialUserAccessRoles < ActiveRecord::Migration
  def change
    UserAccessRole.create(
        role:   :employee,
        label:  "Employee",
        active: true
    )
    UserAccessRole.create(
        role:   :manager,
        label:  "Manager",
        active: true
    )
    UserAccessRole.create(
        role:   :admin,
        label:  "Admin",
        active: true
    )
  end
end
