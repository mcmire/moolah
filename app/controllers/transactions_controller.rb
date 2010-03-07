Moolah.controller :transactions do
  
  get :index do
    @transactions = Transaction.all(:order => "settled_on desc")
    render 'transactions/index'
  end
  
  get :upload do
    render 'transactions/upload'
  end
  post :upload do
    num_transactions_saved = Transaction.import!(params[:file][:tempfile])
    if num_transactions_saved == 0
      flash[:notice] = "No transactions were imported!"
    else
      flash[:success] = format_message(num_transactions_saved, "transaction", "successfully imported.")
    end
    redirect url(:transactions, :index)
  end
  
  get :delete, :with => :id do
    @transaction = Transaction.find(params[:id])
    render 'transactions/delete'
  end
  
  delete :destroy, :with => :id do
    # BUG: Can't use Transaction.destroy(params[:id]) here for some reason
    Transaction.find(params[:id]).destroy
    flash[:success] = "Transaction was successfully deleted."
    redirect url(:transactions, :index)
  end
  
  delete :destroy_multiple do
    # BUG: MongoMapper's find method doesn't seem to autoconvert an array of id strings (but it does auto-convert a single id)
    ids = Array(params[:to_delete]).map {|id| Mongo::ObjectID.from_string(id) }
    transactions = Transaction.find(ids)
    transactions.each(&:destroy)
    flash[:success] = format_message(transactions.size, "transaction", "successfully deleted.")
    redirect url(:transactions, :index)
  end
  
  get :clear do
    Transaction.delete_all
    redirect url(:transactions, :index)
  end
  
  post :dispatch do
    if params[:delete_checked]
      if params[:to_delete].present?
        # BUG: MongoMapper's find method doesn't seem to autoconvert an array of id strings (but it does auto-convert a single id)
        @ids = Array(params[:to_delete]).map {|id| Mongo::ObjectID.from_string(id) }
        @transactions = Transaction.find(@ids)
        render "/transactions/delete_multiple"
      else
        flash[:notice] = "You didn't select any transactions to delete."
        redirect url(:transactions, :index)
      end
    end
  end
  
end