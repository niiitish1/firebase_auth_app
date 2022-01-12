class ProductDetails {
  String? productName;
  String? productDesc;
  String? productPrice;
  String? productImg;

  ProductDetails(
      {this.productName, this.productDesc, this.productPrice, this.productImg});

  ProductDetails.fromJson(Map<String, dynamic> json) {
    productName = json["product_name"];
    productDesc = json["product_desc"];
    productPrice = json["product_price"];
    productImg = json["product_img"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["product_name"] = productName;
    data["product_desc"] = productDesc;
    data["product_price"] = productPrice;
    data["product_img"] = productImg;
    return data;
  }
}
