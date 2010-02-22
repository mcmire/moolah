Moolah.controllers do
  
  get :index do
    @transactions = Transaction.all(:order => "settled_on desc")
    render 'index'
  end
  
  get :upload do
    render 'upload'
  end
  post :upload do
    Transaction.import!(params[:file][:tempfile])
    redirect url(:index)
  end
  
  get :clear do
    Transaction.delete_all
    redirect url(:index)
  end
  
end