Moolah.controllers do
  
  get :index do
    @transactions = Transaction.all(:order => "settled_on desc")
    render 'index'
  end
  
  get :upload do
    render 'upload'
  end
  post :upload do
    num_transactions_saved = Transaction.import!(params[:file][:tempfile])
    if num_transactions_saved == 0
      flash[:notice] = "No transactions were imported!"
    else
      flash[:success] = "#{num_transactions_saved} " + (num_transactions_saved == 1 ? "transaction" : "transactions") + " were successfully imported."
    end
    redirect url(:index)
  end
  
  get :clear do
    Transaction.delete_all
    redirect url(:index)
  end
  
end