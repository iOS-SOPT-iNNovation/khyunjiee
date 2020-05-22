# URLSession 알아보기

✔️실습하면서 공부할 어플의 기능

> iTunes Search API로 쿼리하고, 30초 미리듣기 노래를 다운로드할 수 있다.
> 완성된 앱은 백그라운드 전송을 지원하고, 다운로드를 일시 중지, 재개 또는 취소가 가능하다.



현재 상태는 검색 바만 있는 모습이다.
![image-20200523070819889](/Users/hyunji/Library/Application Support/typora-user-images/image-20200523070819889.png)



### Data Task

유저가 검색하는 단어를 iTunes Search API로 쿼리하는 데이터 테스크를 생성한다.

```swift
  // URLSession을 생성하고 기본 세션 구성을 default로 초기화
  let defaultSession = URLSession(configuration: .default)
  // 새로운 검색어를 재작성하는 시간마다 재 초기화
  var dataTask: URLSessionDataTask?
```

먼저, QueryService.swift에 URLSession을 생성하고, URLSessionDataTask 변수를 선언해서 유저가 검색을 했을 때 iTunes Search 웹 서버로 HTTP GET 요청을 만들어서 사용한다.
데이터 테스크는 새로운 검색어를 재작성하는 시간마다 재 초기화되어진다.



```swift
  func getSearchResults(searchTerm: String, completion: @escaping QueryResult) {
    // 새로운 사용자 쿼리가 이미 존재한다면 데이터 테스크를 취소한다.
    dataTask?.cancel()
    
    // 쿼리 URL에서 사용자 검색 문자열을 포함한다.
    if var urlComponents = URLComponents(string: "https://itunes.apple.com/search"){
      urlComponents.query = "media=music&entity=song&term=\(searchTerm)"
      
      guard let url = urlComponents.url else { return }
      
      // 생성한 세션에서 url쿼리와 URLSessionDataTask를 초기화하고 데이터 테스크가 완료될 때 completion handler를 호출한다.
      dataTask = defaultSession.dataTask(with: url) { data, response, error in
        defer { self.dataTask = nil }
                                                     
        // 요청 성공시 updateSearchResults를 호출
        if let error = error {
          self.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
        } else if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
          self.updateSearchResults(data)
          
          // main queue에서 completion을 전달해줌
          DispatchQueue.main.async {
            completion(self.tracks, self.errorMessage)
          }
        }
        
      }
      dataTask?.resume()
    }
    
  }
```

그 후에 getSearchResults 함수를 선언한다.
새로운 사용자 쿼리가 존재한다면 데이터 테스크 객체를 재사용할 것이다.
또한 사용자의 검색 문자열을 포함하기 위해 searchTerm을 쿼리 URL에 포함해준다.
모든 작업은 기본적으로 일시정지 상태로 시작되기 때문에 resume()을 포함해준다.

*(default 요청의 메소드는 GET. 데이터 테스크를 POST, PUT, DELETE로 원한다면 URLRequest를 생성하여 HTTPMethod 속성을 구성한 후 URL 대신 URLRequest와 데이터 테스크를 생성해야 한다.)*



앱을 빌드해주면 테이블 뷰에 검색 트랙 결과가 채워진 것을 볼 수 있다.
![image-20200523070842594](/Users/hyunji/Library/Application Support/typora-user-images/image-20200523070842594.png)



### Download Task

노래를 다운로드할 수 있는 기능을 추가해준다.



**Download Class**

여러개의 다운로드를 조절하고, 활성 다운로드 상태를 유지하기 위해 모델을 만들어준다.

```swift
class Download {
  
  // 다운로드할 track. url 프로퍼티는 download에 대한 식별자 역할
  var track: Track
  init(track: Track) {
    self.track = track
  }
  
  // track을 다운로드 하는 URLSessionDownloadTask
  var task: URLSessionDownloadTask?
  var isDownloading = false
  var resumeData: Data?
  
  // 다운로드 진행 정도
  var progress: Float = 0
 
}
```



그 후에 DownloadService에 activeDownloads 프로퍼티를 추가한다.

```swift
var activeDownloads: [URL: Download] = [:]
```

URL과 다운로드중인 것 사이에 맵핑을 관리한다.



### URLSessionDownloadDelegate

완료 핸들러로 다운로드 작업을 생성할 수 있다.
URLSessionDownloadDelegate는 다운로드 작업에 작업 수준의 이벤트를 처리한다.

```swift
extension SearchViewController: URLSessionDownloadDelegate {
  func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                  didFinishDownloadingTo location: URL) {
    print("Finished downloading to \(location).")
  }
}
```

urlSession(_:downloadTask:didFinishDownloadingTo:)은 다운로드가 완료될 때마다 메시지를 출력한다.



### Creating Downloading Task

뷰 컨트롤러 viewDidLoad() 전에 lazy var를 추가해준다.

```swift
  lazy var downloadsSession: URLSession = {
    let configuration = URLSessionConfiguration.background(withIdentifier:
    "bgSessionConfiguration")
    return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
  }()
```

별도의 세션을 초기화하고, 델리게이터 호출로 URLSession 이벤트를 받는 델리게이터를 지정한다.
이것은 진행상황을 모니터링한다.

downloadSession이 lazy인데, 세션 초기화에 델리게이터 매개변수를 전달할 수 있는 뷰 컨트롤러가 초기화가 될 때까지 세션 생성이 지연된다 (사실 잘 이해가지 않음..)

```swift
downloadService.downloadsSession = downloadsSession
```

그리고 viewDidLoad()에 세션을 서비스에 적용해준다.

여기까지 하면 세션과 델리게이터가 구성되어 track 다운로드 사용자가 요청할 때 다운로드가 생성할 준비가 된 것이다.



DownloadService.swift의 startDownload(_:) 함수를 구현해준다.

```swift
  func startDownload(_ track: Track) {
    // 다운로드 초기화
    let download = Download(track: track)
    // 트랙 미리보기 URL로 다운로드 테스크를 생성해 task 프로퍼티를 설정한다.
    download.task = downloadsSession.downloadTask(with: track.previewURL)

    download.task!.resume()
    // 다운로드가 진행중임을 나타냄
    download.isDownloading = true
    // activeDownloads 디렉토리 안에 다운로드 URL을 매핑한다.
    activeDownloads[download.track.previewURL] = download
  }
```

사용자가 테이블뷰 셀의 Download 버튼을 누를 때, TrackCellDelegate로 동작하는 SearchViewController는 셀에 대한 트랙을 식별하고 이 트랙으로 startDownload(_:)를 호출한다.

여기까지 하면 다운로드를 눌렀을 때 버튼이 남아있는데 다음번에 지우는 것 까지 하겠음!