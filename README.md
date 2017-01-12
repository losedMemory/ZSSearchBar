# ZSSearchBar
- 🔍 利用苹果原生的UISearchBar做的一个搜索demo
 ## 结构
* 数据库存储数据sql语句查询数据
* 沙盒存储搜索历史数据
* 本想使用两个tableView,但是在一个控制器中使用两个tableView代理方法和数据源方法要进行很多判断,很容易出错,所以我采取的是一个tableView,一个UITableViewController,这样简单一点
* tableView中显示的是搜索历史记录,ZSSearchResultViewController显示的是搜索结果
 ![image](https://github.com/losedMemory/ZSSearchBar/blob/master/searchBar.gif)

