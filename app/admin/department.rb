ActiveAdmin.register Department do
  menu priority: 3, parent: 'Manage'
  permit_params :user_id, :name, :phone_number, :unclaimed_response

  index do
    column :name
    column :phone_number
    column :unclaimed_user
    actions
  end

  form do |f|
    f.inputs do
      if resource.persisted?
        f.input :user_id, as: :select, collection: User.where(department: resource)
      end
      f.input :name
      f.input :phone_number
      f.input :unclaimed_response
    end
    f.actions
  end

  controller do
    def destroy
      if resource.users.any?(&:active)
        flash[:error] = 'Cannot delete a department with active users.'
        redirect_back(fallback_location: admin_departments_path)
      else
        super
      end
    end
  end
end
