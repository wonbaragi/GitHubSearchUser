# GitHubSearchUser

프로젝트 진행을 위해서 MVVM 과 RXSwift 도입을 검토하면서 해봤습니다.

# 개발 환경

- Apple M1 Pro 
- Xcode Version : 13.2.1 
- Swfit Version : 5 
- Target SDK Version : 13

# 프로젝트 설명

MVVM + RXSwift + Observable 를 사용
StoryBoard를 사용하여 UI를 생성.
Github Search User API을 사용 (https://docs.github.com/en/rest/reference/search#search-users--code-samples)
로컬 데이터는 Realm을 사용.
로컬탭의 section을 위해서 FavoriteUserTableViewDataSource 정의하여 사용
(Realm의 데이터를 가지고 온 뒤 초성으로 묶음 처리)

# 향후 개선 사항
- 탭 동작 시 기존에 설정된 검색 키워드와 테이블의 스크롤 위치 고정이 필요한가?
- 위 SearchAPI 에서는 login 값을 userName 으로 사용하였는데.. 가끔 검색 결과가 다른게 나오고 있음. 결과에 대한 원인 파악이 필요?
 ex) w를 검색하면 login 값에 w가 없어도 검색 결과에 나옴.
- 페이지 처리에 대한 동작 추가 필요. 불필요한 API 호출을 막기 위한 방법 필요.
- Realm 이용한 Tableview Data mapping 의 delete 동작 시 문제가 있음. tableview data 연결 방법을 생각해봐야 겠음
- cell 의 favotire button 동작이 예상과 다름... rx의 문제인지??

# 사용한 framwork

PODS:
  - Alamofire (5.5.0)
  - Differentiator (5.0.0)
  - ObjectMapper (4.2.0)
  - Realm (10.24.2):
    - Realm/Headers (= 10.24.2)
  - Realm/Headers (10.24.2)
  - RealmSwift (10.24.2):
    - Realm (= 10.24.2)
  - RxCocoa (6.5.0):
    - RxRelay (= 6.5.0)
    - RxSwift (= 6.5.0)
  - RxDataSources (5.0.0):
    - Differentiator (~> 5.0)
    - RxCocoa (~> 6.0)
    - RxSwift (~> 6.0)
  - RxGesture (4.0.4):
    - RxCocoa (~> 6.0)
    - RxSwift (~> 6.0)
  - RxRelay (6.5.0):
    - RxSwift (= 6.5.0)
  - RxSwift (6.5.0)
  - SwiftyJSON (5.0.1)
