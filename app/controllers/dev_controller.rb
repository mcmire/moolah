Moolah.controller :dev do
  
  get :test do
    render "dev/test"
  end
  
  get :button_test do
    render "dev/button_test", :layout => :"layouts/plain"
  end
  
end