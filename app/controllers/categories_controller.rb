Moolah.controller :categories do
  
  restful :index do
    @categories = Category.order_by([:name, :asc])
    render 'categories/index'
  end
  
  restful :new do
    @category = Category.new
    render 'categories/new'
  end
  restful :create do
    @category = Category.new
    @category.attributes = params[:category]
    if @category.save
      flash[:success] = "Category successfully added."
      redirect url(:categories, :index)
    else
      render 'categories/new'
    end
  end
  
  restful :edit do
    @category = Category.find(params[:id])
    render 'categories/edit'
  end
  restful :update do
    @category = Category.find(params[:id])
    @category.attributes = params[:category]
    if @category.save
      flash[:success] = "Category successfully updated."
      redirect url(:categories, :index)
    else
      render 'categories/edit'
    end
  end
  
  restful :delete do
    @category = Category.find(params[:id])
    render 'categories/delete'
  end
  restful :destroy do
    category = Category.find(params[:id])
    category.destroy
    flash[:success] = "Category was successfully deleted."
    redirect url(:categories, :index)
  end
  
  delete :destroy_multiple do
    ids = Array(params[:to_delete])
    categories = Category.criteria.in(:_id => ids)
    categories.each(&:destroy)
    flash[:success] = format_message(ids.size, "category", "successfully deleted.")
    redirect url(:categories, :index)
  end
  
  post :dispatch do
    if params[:delete_checked]
      if params[:to_delete].present?
        @ids = Array(params[:to_delete])
        @categories = Category.criteria.in(:_id => @ids)
        render "/categories/delete_multiple"
      else
        flash[:notice] = "You didn't select any categories to delete."
        redirect url(:categories, :index)
      end
    end
  end
  
end