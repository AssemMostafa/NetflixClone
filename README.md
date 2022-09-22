# Netflix Clone Task

# Intoduction
This is a brief description about Netflix Clone iOS programming task.

# Networking
The networking layer used in this project consists of 2 main parts

  - APICaller - a request holds all data related to a specafic request (HTTP method, headers, response type etc), a response is responsible for parsing the raw data it recieves and also it is responsible for converting Http errors and status codes to application specfic errors, a task represent an network operation on a specafic resource, the task is also responsible for parsing the json/data it recieves to the operation specfic data type.
 
  - DataPersistenceManger - a Manger manipulate all data related to a specafic request (save, fetch and delete) data with core data database layer.

# Application architecture
This application uses MVVM architecture with flow coordinators, The application has a 2 View models, the TitleViewModel which is responsible for displaying a list of movies and the TitlePreviewViewModel which is responsible for displaying a single movie. The application also has four Flow controllers which are : 
  - HomeViewController - it is responsible for initiating the application home list of movies.
  - UpComingViewController - it is responsible for upcoming the movies.
  - SearchViewController - it is responsible for Searching specific movie.
  - DownloadsViewController - it is responsible for downloading specific movie.



# Created by
Ahmed Assem



