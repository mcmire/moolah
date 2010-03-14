Moolah.controller :transactions do
  
  get :index, :map => "/transactions(/:account_id)(/)" do
    session[:last_account_id] = @account_id = params[:account_id]
    options = {:order => "settled_on desc"}
    options[:account_id] = @account_id if @account_id
    @transactions = Transaction.all(options)
    render 'transactions/index'
  end
  
  get :new do
    @transaction = Transaction.new(:amount => 0, :settled_on => Date.today)
    @last_account_id = session[:last_account_id]
    render 'transactions/new'
  end
  post :create, :map => "/transactions(/)" do
    @transaction = Transaction.new
    @transaction.attributes = params[:transaction]
    @transaction.amount *= 100.0
    @transaction.amount *= -1.00 if params[:transaction_kind] == "debit"
    if @transaction.save
      flash[:success] = "Transaction successfully added."
      redirect url(:transactions, :index, :account_id => session[:last_account_id])
    else
      render 'transactions/new'
    end
  end
  
  get :edit, :map => "/transactions/:id/edit(/)" do
    @transaction = Transaction.find(params[:id])
    @last_account_id = session[:last_account_id]
    render 'transactions/edit'
  end
  put :update, :map => "/transactions/:id(/)" do
    @transaction = Transaction.find(params[:id])
    @transaction.attributes = params[:transaction]
    @transaction.amount *= 100.0
    @transaction.amount *= -1.00 if params[:transaction_kind] == "debit"
    if @transaction.save
      flash[:success] = "Transaction successfully updated."
      redirect url(:transactions, :index, :account_id => session[:last_account_id])
    else
      render 'transactions/edit'
    end
  end
  
  get :delete, :map => "/transactions/:id/delete(/)" do
    @transaction = Transaction.find(params[:id])
    render 'transactions/delete'
  end
  delete :destroy, :map => "/transactions/:id(/)" do
    # BUG: Can't use Transaction.destroy(params[:id]) here for some reason
    Transaction.find(params[:id]).destroy
    flash[:success] = "Transaction was successfully deleted."
    redirect url(:transactions, :index, :account_id => session[:last_account_id])
  end
  
  delete :destroy_multiple do
    # BUG: MongoMapper's find method doesn't seem to autoconvert an array of id strings (but it does auto-convert a single id)
    ids = Array(params[:to_delete]).map {|id| Mongo::ObjectID.from_string(id) }
    transactions = Transaction.find(ids)
    transactions.each(&:destroy)
    flash[:success] = format_message(transactions.size, "transaction", "successfully deleted.")
    redirect url(:transactions, :index, :account_id => session[:last_account_id])
  end
  
  get :upload, :map => "/transactions/:account_id/upload(/)" do
    @account_id = params[:account_id]
    render 'transactions/upload'
  end
  post :upload, :map => "/transactions/:account_id/upload(/)" do
    account_id = params[:account_id]
    num_transactions_saved = Transaction.import!(params[:file][:tempfile], account_id)
    if num_transactions_saved == 0
      flash[:notice] = "No transactions were imported!"
    else
      flash[:success] = format_message(num_transactions_saved, "transaction", "successfully imported.")
    end
    redirect url(:transactions, :index, :account_id => params[:account_id])
  end
  
  get :clear do
    Transaction.delete_all
    redirect url(:transactions, :index, :account_id => session[:last_account_id])
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
        redirect url(:transactions, :index, :account_id => session[:last_account_id])
      end
    end
  end
  
end