module StyleHelper
  def label_class
    "absolute text-gray-500 duration-300 transform -translate-y-4 scale-90 top-2 z-10 origin-[0] bg-white px-2 peer-focus:px-2 peer-placeholder-shown:scale-100 peer-placeholder-shown:-translate-y-1/2 peer-placeholder-shown:top-1/2 peer-focus:top-2 peer-focus:-translate-y-5 rtl:peer-focus:translate-x-1/4 rtl:peer-focus:left-auto start-1"
  end
  
  def input_class
    "block px-2.5 pb-2.5 pt-4 w-full text-sm text-gray-900 bg-transparent rounded-lg border border-gray-300 appearance-none focus:outline-none focus:ring-0 focus:border-gray-400 peer"
  end  

  def label_class_for_select
    "absolute text-gray-500 transform -translate-y-5 scale-90 top-2 z-10 origin-[0] bg-white px-2 start-1"
  end

  def form_button_class
    "bg-red-600 hover:bg-red-700 text-white py-2 px-4 rounded cursor-pointer"
  end
  

  def secondary_button_class
    "bg-white text-red-600 hover:bg-red-600 hover:text-white py-2 px-4 rounded border border-red-600 mr-2"
  end

  def radio_button_class
    "h-4 w-4 text-buttonRed focus:ring-buttonRed border-formInputBorder rounded-full"
  end

  def radio_label_class
    "ml-2"
  end
end