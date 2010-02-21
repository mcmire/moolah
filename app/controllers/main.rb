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
    redirect '/'
  end
  
end