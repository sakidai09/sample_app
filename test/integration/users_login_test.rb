require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  test "login with invalid information" do #正しくない情報でログインしようとした場合
    get login_path #loginのページにとばされる
    assert_template 'sessions/new' # 正しく表示されていることを確認
    post login_path, params: { session: { email: "", password: "" } } #セッションにemaiとpasが空だとloginページに戻される
    assert_template 'sessions/new' # 正しく表示されていることを確認
    assert_not flash.empty? #フラッシュメッセージがあるはず
    get root_path #TOPページへ
    assert flash.empty? #フラッシュメッセージは空にする
  end


  test "login with valid information followed by logout" do
    get login_path
    post login_path, params: { session: { email:@user.email, password: 'password' } }
    assert is_logged_in?
    assert_redirected_to @user
    follow_redirect!
    assert_template 'users/show'
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_url
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path,      count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end
end