Moolah.controller :import_rules do
  
  restful :index do
    @import_rules = ImportRule.all
    render 'import_rules/index'
  end
  
  restful :new do
    @import_rule = ImportRule.new
    render 'import_rules/new'
  end
  restful :create do
    @import_rule = ImportRule.new
    @import_rule.attributes = params[:import_rule]
    if @import_rule.save
      flash[:success] = "Import rule successfully added."
      redirect url(:import_rules, :index)
    else
      render 'import_rules/new'
    end
  end
  
  restful :edit do
    @import_rule = ImportRule.find(params[:id])
    render 'import_rules/edit'
  end
  restful :update do
    @import_rule = ImportRule.find(params[:id])
    @import_rule.attributes = params[:import_rule]
    if @import_rule.save
      flash[:success] = "Import rule successfully updated."
      redirect url(:import_rules, :index)
    else
      render 'import_rules/edit'
    end
  end
  
  restful :delete do
    @import_rule = ImportRule.find(params[:id])
    render 'import_rules/delete'
  end
  restful :destroy do
    rule = ImportRule.find(params[:id])
    rule.destroy
    flash[:success] = "Import rule was successfully deleted."
    redirect url(:import_rules, :index)
  end
  
  delete :destroy_multiple do
    ids = Array(params[:to_delete])
    import_rules = ImportRule.criteria.in(:_id => ids)
    import_rules.each(&:destroy)
    flash[:success] = format_message(ids.size, "import rule", "successfully deleted.")
    redirect url(:import_rules, :index)
  end
  
  post :dispatch do
    if params[:delete_checked]
      if params[:to_delete].present?
        @ids = Array(params[:to_delete])
        @import_rules = ImportRule.criteria.in(:_id => @ids)
        render "/import_rules/delete_multiple"
      else
        flash[:notice] = "You didn't select any import rules to delete."
        redirect url(:import_rules, :index)
      end
    end
  end
  
end