import 'package:my_shop/models/product_details.dart';
import 'package:my_shop/models/user_details.dart';

const appName = "MyShop";
const logInText = "Login";
const singupText = 'Signup';
const thisField = 'This field cannot be empty';
const imgPost = 'usersPhoto';
const userDetails = 'users';
const fireStoreRef = 'products';
UserDetails? userData;

List<ProductDetails> productList = [];
int whichIndex = -1;
