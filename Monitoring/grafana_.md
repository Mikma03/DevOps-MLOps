<!-- TOC -->

- [OReily - Ronald McCollam - Getting Started with Grafana](#oreily---ronald-mccollam---getting-started-with-grafana)
  - [Short intro](#short-intro)
  - [Deploying Grafana Locally](#deploying-grafana-locally)
  - [Connecting to Data Sources](#connecting-to-data-sources)
  - [Advanced Deployment and Management](#advanced-deployment-and-management)
  - [Programmatic Grafana](#programmatic-grafana)
  - [Grafana Provisioning](#grafana-provisioning)
  - [Grafana Enterprise](#grafana-enterprise)
- [Sean Bradley Udemy Course - Grafana](#sean-bradley-udemy-course---grafana)
  - [Installation](#installation)
  - [Dashboard - Panel videos](#dashboard---panel-videos)
  - [Data Source, Collector and Dashboard](#data-source-collector-and-dashboard)
  - [Prometheus](#prometheus)
- [Grafana - Machine Learning](#grafana---machine-learning)

<!-- /TOC -->

# OReily - Ronald McCollam - Getting Started with Grafana

- https://learning.oreilly.com/library/view/getting-started-with/9781484283097/

## Short intro

As a widely used open source tool, Grafana can be deployed in a nearly limitless number of ways and at scales ranging from a single instance on a pocket-sized Raspberry Pi up to highly available multiregion deployments with hundreds of nodes. Figuring out the best way to deploy it for your own environment can seem a bit daunting.

Fortunately, Grafana is also available as Software as a Service (SaaS), meaning that someone else has already done all the work to set it up correctly and make it available to you to sign up and use automatically. Since Grafana is open source, anyone can host a SaaS Grafana service. And because Grafana continues to grow in popularity, there are a growing number to choose from.

Grafana ships with a number of powerful visualizations natively, as well as functionality to let you run ad hoc queries to find the data you’re looking for.

Grafana visualizes data but doesn’t actually store it – it relies on external data sources to provide the actual data and a way to retrieve it. 

## Deploying Grafana Locally

- https://learning.oreilly.com/library/view/getting-started-with/9781484283097/html/521586_1_En_3_Chapter.xhtml#:-:text=Deploying%20Grafana%20Locally

Grafana is intentionally built to be both self-contained and portable. This means that it runs with few external dependencies (additional libraries or software packages that are not already part of most operating systems) and that it can run on a wide variety of hardware and operating system platforms.

When you download Grafana, you’ll see that it’s provided in two editions, OSS and Enterprise. OSS refers to Open Source Software, meaning a completely open edition of Grafana with full source code available. The Grafana Enterprise package provides more functionality than the pure open source Grafana package, though it requires a license key for the extra features to be enabled. Without the license, the Grafana Enterprise package will function exactly the same as the open source package.

## Connecting to Data Sources

- https://learning.oreilly.com/library/view/getting-started-with/9781484283097/html/521586_1_En_4_Chapter.xhtml#:-:text=Connecting%20to%20Data%20Sources

Since Grafana doesn’t actually store your data directly, to visualize real data we need to connect Grafana to the data sources where that data resides. A data source in Grafana is a plugin that provides a connection to the application or service that contains the data.

It’s important to note that data sources must provide a query interface in order for Grafana to retrieve data. It has to provide some sort of API or interface that lets you ask for the specific data you want. If there’s no way to request data from your system directly, there’s no way for Grafana to get it and thus no way for Grafana to display it. What that query interface looks like is up to the data source – as long as it exists and can provide a result when queried, Grafana can work with it. (At least in theory; someone still has to go through the work of writing the plugin before you can use it.) The type of query it supports can be complex and expressive, like SQL, or much simpler, like requesting a specific cell or range from a Google Sheet spreadsheet. But the mechanism for running the query must exist for the data to be used in Grafana.

Data sources also format the results of your query in a way that Grafana can understand. Grafana expects all data to be formatted in a single, specific way regardless of how the data is actually stored or formatted originally. So the data source plugin has to take the source data and manipulate it so that it matches the format that Grafana expects. If this didn’t happen, every single panel type would need to be able to process data from every possible source. Every time you wanted to connect a new data source to Grafana, you’d have to update the code for every single possible visualizatio.

**Data frames**

https://grafana.com/docs/grafana/latest/developers/plugins/data-frames/

Grafana supports a variety of different data sources, each with its own data model. To make this possible, Grafana consolidates the query results from each of these data sources into one unified data structure called a data frame.


Each entry in the data source configuration view represents one connection to an application or service. It’s entirely possible – even common! – to have multiple connections to the same data source. For example, you might have more than one SQL database on a single server. You only need to install the data source plugin once, and then you can create as many connections to that data source as you like.

**InfluxDB**

https://www.influxdata.com/

InfluxDB is an open source time series database and query engine. It’s commonly used for monitoring physical or virtual computer systems as well as sensors or IoT devices. InfluxDB has been around since 2013 and is often used with the Telegraf agent. Telegraf supports over 200 different plugins for collecting data from a wide array of software and hardware, making it a great way to get started with monitoring generally.


**Prometheus**

Prometheus is a popular open source metric store, created in 2012 at SoundCloud and moved to the Cloud Native Computing Foundation in 2016. Since then, Prometheus has steadily increased in popularity due both to being easy to deploy and being the default metric system for Kubernetes, a widely used container orchestration system.

Unlike many other metric collection systems which run an agent on monitored devices and push data to a central server, by default Prometheus uses a pull model: a central Prometheus server is configured with locations where it can find data, and it pulls (or scrapes in Prometheus language) the metrics from the systems being monitored. 

Prometheus exposes its metric query interface via HTTP, by default on port 9090. So if you are running Prometheus and Grafana on the same server, you can likely access Prometheus via http://localhost:9090. If they’re not on the same server, remember that Grafana needs to be able to access the Prometheus instance over the network in order to display data. So if you are running Prometheus inside your firewall but want to run Grafana in the cloud, you’ll need to configure your network to allow this.

Once set up, you will be able to query Prometheus data! (Though remember that if you’re using the Prometheus data source in Grafana Cloud Metrics, there won’t be any data in there by default. You’ll still need to send some data using the Grafana Agent or some other method before you can query anything.)


**Graphite**

Graphite is older than InfluxDB and Prometheus, the other two time series databases in this chapter, dating to 2006 at Orbitz. But while these newer systems may generate more buzz now, Graphite is still widely used and is in production at some of the largest Internet and ecommerce services.

Graphite is a core Grafana plugin, meaning that it’s included by default and easy to configure without adding anything extra to Grafana. Grafana Cloud Metrics provides a Graphite endpoint by default, so if you have created a Grafana Cloud account already, you already have access to a Graphite environment and can start visualizing data in Grafana.


**MySQL**

MySQL is one of the most commonly used open source SQL databases, popular among web developers for its simplicity of deployment and management. If a web host offers only a single database option, odds are MySQL will be it. This means that for non-time series data like content storage, product sales, or other business data, it’s a natural fit. Being able to display this data alongside of monitoring and logging data in Grafana lets you look at your whole environment in one place.

Because MySQL is a core plugin for Grafana, you won’t need to install anything extra to be able to connect to it and start visualizing your data. Unlike the time series databases covered earlier in the chapter, MySQL does not have its own built-in web interface. Instead, it listens for connections using its own protocol on port 3306. So unless you’ve changed your MySQL configuration, you’ll need to be sure that port is accessible from your Grafana server. If they are running on the same system, you can probably use localhost:3306 to connect, but if your Grafana instance is outside your firewall (e.g., in Grafana Cloud), you’ll need to make the necessary network configuration changes to allow inbound access to your MySQL environment.


**PostgreSQL**

PostgreSQL, like MySQL, is a widely used open source SQL database. PostgreSQL has a strong emphasis on correctness and robustness, meaning that while it might take a bit of expertise to configure perfectly, it is ideal for mission-critical data.

Because PostgreSQL is a core plugin for Grafana, you won’t need to install anything extra to be able to connect to it and start visualizing your data. PostgreSQL does not provide a built-in web interface like the time series databases we looked at earlier. Instead, it listens for connections using its own protocol on port 5432. So unless you’ve changed your PostgreSQL configuration, you’ll need to be sure that port is accessible from your Grafana server. If they are running on the same system, you can probably use localhost:5432 to connect, but if your Grafana instance is outside your firewall (e.g., in Grafana Cloud), you’ll need to make the necessary network configuration changes to allow inbound access to your PostgreSQL environment.


**Loki**

Grafana is most known for visualizing time series data, but it’s fully capable of querying and displaying log data as well. Loki is a newer open source project, started in 2018, but has quickly grown in popularity due to its lightweight indexing system and close ties to Prometheus. It also uses Grafana as its primary user interface, meaning that Prometheus, Loki, and Grafana all work seamlessly together.


**Elasticsearch**

Elasticsearch is one of the oldest and most widely adopted open source tools for log aggregation and searching. While Elasticsearch is not actually limited to working with just log data, it works extremely well for this use case.

Elasticsearch can be run locally or consumed as a service online. The configuration for these is the same in Grafana, so to make things easy we’ll look at using Elasticsearch as a service in this example. Elastic provides a free 14-day trial of Elasticsearch at www.elastic.co along with some sample data that you can import if you don’t have data of your own. You can also use tools such as Elastic Beats or Logstash to send in data. Be sure you have some data, either real or sample data, available in Elasticsearch before you try to run queries in Grafana.


___

## Advanced Deployment and Management

- https://learning.oreilly.com/library/view/getting-started-with/9781484283097/html/521586_1_En_12_Chapter.xhtml#:-:text=Advanced%20Deployment%20and%20Management

By default, Grafana uses a file-based database system called SQLite. SQLite is a mature (20+ years old) public domain SQL database engine that is designed to be small, fast, and reliable. Unlike most other SQL databases, however, SQLite doesn’t run as a service that listens for queries and responds with results; instead, it runs as a library in memory within another program and performs all of its queries and writes on a file on disk.

Since SQLite is so small and doesn’t require setting up any additional services, it’s a perfect fit for most Grafana environments. But SQLite does have a few drawbacks: it’s designed to be used by a single client at a time, and since it stores all data in a single file, it can be limited in size and speed as there’s no good way to parallelize access to that one file. This means that your Grafana environment can grow too large for efficient use of SQLite, and if you want to have Grafana configured for high availability, you’ll need to support multiple simultaneous systems accessing the data. Or you may just have requirements to use database systems that are already in use and being actively managed in your organization.

In any of these cases, you’ll need to configure Grafana to use an external database service such as MySQL or PostgreSQL. Grafana’s functionality is unchanged in this case; the only difference is the location where it keeps its own configuration data.



___

## Programmatic Grafana

- https://learning.oreilly.com/library/view/getting-started-with/9781484283097/html/521586_1_En_13_Chapter.xhtml#:-:text=Programmatic%20Grafana

Up until now, all the ways that we have seen to use Grafana have been through its web user interface. This UI is fantastic for creating dashboards, laying out panels, and organizing resources. But when you need to manage Grafana at a large scale or as part of a continuous deployment system, having to click buttons and type information into text boxes can be slow and limiting. Fortunately, Grafana provides a rich application programming interface (API) for automating these actions.

Like most modern web applications, Grafana is based on the idea of representational state transfer, or REST.

REST is really just a fancy (and formal) way of saying that every request that is sent to the application is independent of any other request. That is, when you access a URL and request a resource, the web application doesn’t automatically remember who you are or what requests you’ve made in the past. You need to provide this context about your request, which REST calls state, every time you make a new request.

The upshot of this is that each time you ask for a resource from or send information to Grafana, you need to include all the state that Grafana needs to fulfill that request. This includes things like authentication, so you’ll need to include your credentials with every request. It also means that you have to be explicit about what resource you are asking Grafana to modify – just because you made an update to a specific dashboard a moment ago doesn’t mean that Grafana will remember that! You’ll need to explicitly tell Grafana everything about what you want it to do, where you want that to happen, and who you are with each request.


**Adding API Keys**

- https://learning.oreilly.com/library/view/getting-started-with/9781484283097/html/521586_1_En_13_Chapter.xhtml#:-:text=Adding%20API%20Keys

Grafana API keys are OAuth 2.0 bearer tokens. This means that in order to work, they need to be included as a header in every HTTP request

This API controls almost every aspect of Grafana from configuration to operation and even monitoring the health of Grafana itself.

The full API is documented on the Grafana website at 

- https://grafana.com/docs/grafana/latest/

It’s important to know a bit about how Grafana represents resources internally. Almost everything in Grafana – dashboards, folders, data source configuration, you name it – is represented in JSON format. JSON is a data serialization format, which is a fancy way of saying that it can represent complex, multidimensional data structures in a simple form.

When you create a dashboard in the Grafana UI, Grafana is representing that dashboard as a JSON object in the background. So when you use the API to retrieve or update a dashboard, you’ll be seeing that JSON format a lot.

The good news is that JSON is just a text format, so working with it is like working with any other plain text. You can save it, edit it, or check it into source control as you like, and there are a number of tools available for working with it directly. Having JSON as a format for all Grafana data makes it easy to connect to other systems or back up data wherever you prefer.

**Dashboards**

- https://learning.oreilly.com/library/view/getting-started-with/9781484283097/html/521586_1_En_13_Chapter.xhtml#:-:text=Dashboards

The dashboards API allows you to manage Grafana dashboards. Using this API, you can get, update, create, or delete dashboards and retrieve some metadata about dashboards such as the tags that have been applied to it.

**Getting Dashboards**

To retrieve the JSON object that defines a dashboard in Grafana, you’ll need to know the dashboard’s unique identifier (UID). This is the string of characters after /d/ in your dashboard URL up to the following slash.

To get the dashboard’s JSON, you can put this UID into the dashboards API and use an HTTP GET on the URL:
https://<your grafana instance>/api/dashboards/uid/<dashboard UID>
This will retrieve the JSON representation of the dashboard with the given UID

**Creating or Updating Dashboards**

Creating and updating a dashboard in Grafana use the same API endpoint. If a dashboard with the specified UID exists, it will be replaced with the one you send to the API. If it doesn’t already exist, it will be created.

To create or update a Grafana dashboard, you will POST data to the API at
https://<your grafana instance>/api/dashboards/db

Note that the URL does not contain the UID of the dashboard; this is set in the JSON object that is the body of the request. You’ll need to ensure that the content-type header of your request is set to application/json in order for Grafana to accept your dashboard. This should be done in your REST client if you’re using one. In Postman, this is set in the details of the “body” tab of the POST request.

**Deleting Dashboards**

- https://learning.oreilly.com/library/view/getting-started-with/9781484283097/html/521586_1_En_13_Chapter.xhtml#:-:text=Deleting%20Dashboards

**Folders**

- https://learning.oreilly.com/library/view/getting-started-with/9781484283097/html/521586_1_En_13_Chapter.xhtml#:-:text=Folders

The folders API lets you manage dashboard folders in your Grafana environment. This includes listing folders, getting and setting the title of folders, and creating and deleting folders.

Listing Folders
To list folders, use an HTTP GET on the folders API, like
https://<your grafana instance>/api/folders
You can optionally add a limit on the number of folders that are returned by this API call by adding the limit parameter. For example, adding ?limit=10 to the end of the URL will return only the first ten dashboards. If you don’t specify a limit, the default limit of 1000 will be used.

This is most useful for finding the unique identifier (UID) of a folder that you want to delete or update. Like with dashboards, the UID is used to tell Grafana which specific folder you want to change or delete.

**Getting Folder Information**

To get the metadata attached to a single folder, you can pass the folder UID into the API call using an HTTP GET:
https://<your grafana instance>/api/folders/<folder UID>
This will return much more information about a dashboard than the name and UID that the dashboard listing API gives. When getting the information about a specific folder, you’ll also see details about when and by whom the folder was created and last updated, permission information, and the full URL to access the folder in Grafana.

**Creating Folders**

To create a folder, use an HTTP POST to the folder API:
https://<your grafana instance>/api/folders
The body of the request should contain a JSON description of the folder. The only required field in this JSON is the folder title; you can optionally add a UID if you want to specify the UID yourself. If you don’t include the UID, one will be automatically generated and returned in the response.

**Updating Folders**

While dashboards use the same API call to create and update data, folders have a separate API call for each. To update a folder, you’ll need to put its UID into the folder API and make an HTTP PUT:
https://<your grafana instance>/api/folders/<folder UID>
In the body of your request, include the data that you want to update. You can change the UID or the title of the folder; the other metadata is managed by Grafana directly.

**Data Sources**

- https://learning.oreilly.com/library/view/getting-started-with/9781484283097/html/521586_1_En_13_Chapter.xhtml#:-:text=Data%20Sources

The data sources API lets you manage the configuration of data sources within Grafana. This API is a bit more flexible than the API endpoints we’ve seen earlier. In addition to working with unique identifiers (UIDs), they can also use data source names or Grafana IDs. For consistency, we’ll continue to use UIDs in the examples here (with one exception, updating; see the updating section for details). If you want to see the other ways to manage data sources via an API, check out the Grafana API documentation.

All uses of the data sources API require an API key with admin permissions. If you try to use a key with viewer or editor permissions, you’ll get an error:


{
    "message": "Permission denied"
}

If you see this, switch to an admin API key and try your request again.

Listing Data Sources
To list data sources, use an HTTP GET on the data sources API endpoint:
https://<your grafana instance>/api/datasources

This will return a list of all data sources configured in your Grafana instance

**Getting Data Source Information**

To retrieve information about a specific data source only, you can use an HTTP GET on the data sources API and pass a specific UID:
https://<your grafana instance>/api/datasources/uid/<data source UID>
This will return the same information as the data source list, but will limit the results to only the data source with the UID provided.

**Creating Data Sources**

To create a data source, use an HTTP POST to the dashboards API:
https://<your grafana instance>/api/datasources/
In the body of the request, include a JSON representation of the data source configuration. (The easiest way to get this is to export a data source using the GET data sources API (mentioned earlier) and modify it to contain the values that you need.) You don’t need to include a UID in this – if you leave it out, Grafana will create one for you and return it in the results.

**Updating Data Sources**

To update a dashboard, use an HTTP PUT to send the updated dashboard to the API:
https://<your grafana instance>/api/datasources/<data source ID>
Unlike most of the other parts of the data sources API, the update API requires you to use the Grafana ID number rather than the UID or name of the data source. You can find this by using the GET data sources API outlined earlier.

The body of the request follows the same rules as for creating a data source; the only difference is that this API call will not create a data source if a data source with the provided ID doesn’t already exist.

**Deleting Data Sources**

To delete a data source, send an HTTP DELETE to the data sources API:
https://<your grafana instance>/api/datasources/uid/<data source UID>
This will delete the data source immediately and return a success message:
{
    "message": "Data source deleted"
}


____

There are a large number of API calls that haven’t been covered here, so if there are things in Grafana that you want to automate, it’s worth looking through the full API documentation. That said, there are a couple of other generally useful API calls that don’t fall into the preceding categories that are worth mentioning.

____


## Grafana Provisioning

- https://grafana.com/docs/grafana/latest/administration/provisioning/

- https://learning.oreilly.com/library/view/getting-started-with/9781484283097/html/521586_1_En_13_Chapter.xhtml#:-:text=Grafana%20Provisioning

The Grafana provisioning system is a set of configuration files and locations on disk that tell Grafana how to configure itself. Through it, you can define where Grafana should look for configuration files that describe the layout of dashboards and folders and set up data sources.

The Grafana API is a great way to automate your Grafana environment once it is up and running. But if you want to completely automate the configuration of Grafana from initial installation through full production, the provisioning system is the way to go.

In previous versions of Grafana, you could only use the API for provisioning data sources and dashboards. But that required the service to be running before you started creating dashboards and you also needed to set up credentials for the HTTP API. In v5.0 we decided to improve this experience by adding a new active provisioning system that uses config files. This will make GitOps more natural as data sources and dashboards can be defined via files that can be version controlled. We hope to extend this system to later add support for users, orgs and alerts as well.


The provisioning system is controlled in grafana.ini, the main Grafana configuration file. It’s enabled by default, meaning that you can put configuration files in the appropriate location with no additional changes to Grafana, and the system will be provisioned when you start it up. By default, configuration files are in <your grafana path>/conf/provisioning, but this can be changed in grafana.ini.


___

## Grafana Enterprise

- https://learning.oreilly.com/library/view/getting-started-with/9781484283097/html/521586_1_En_14_Chapter.xhtml#:-:text=Grafana%20Enterprise

A major component of Grafana Enterprise is support and indemnification. If visualization and alerting on the metrics in your environment is critical to your business, it makes sense to have 24/7 support and protection in the event of any legal issues that arise in your environment. For some organizations, this alone may be worth the price.

Beyond support and legal coverage, Grafana Enterprise extends standard Grafana in a few key ways. It provides additional connectors to data sources that aren’t part of the open source Grafana platform. It provides additional security features that let you limit access to data and data sources, set more fine-grained access controls to features of Grafana, and map those roles as well as team memberships from external authentication systems – and ensure that those changes stay live and in sync across Grafana instances. 

Scheduled PDF reporting, dashboard usage and viewership information, and enhanced searching of dashboards by most/least useful help you collaborate with colleagues more easily. Finally, Grafana Enterprise gives you the option to change the appearance of Grafana itself to more closely match your organization’s style.

Because Grafana Enterprise is a paid product, we’ll only look at some of the highlights here – to fully understand and use Grafana Enterprise, you will need to sign up and pay for a subscription. Once you do this, you can contact Grafana Labs for any help that you need, as support is part of this subscription.


___

# Sean Bradley Udemy Course - Grafana

Dedicated website for course with all docs
- https://sbcode.net/grafana/


___

## Installation

First part is about installing and securing deployment. We can deploy Grafana on any cloud provider and access via browser. 

Deploying Grafana we should add SSH protocol for our access.


Installation link - official docs
- https://sbcode.net/grafana/install-grafana/

Installation udemy instruction
- https://udemy.com/course/grafana-tutorial/learn/lecture/18623720#content


___

## Dashboard - Panel videos

- Panel Rows
  - https://udemy.com/course/grafana-tutorial/learn/lecture/16341530#content

- Panel Presentation Options
  - https://udemy.com/course/grafana-tutorial/learn/lecture/16343082#content

- Dashboard Versioning
  - https://udemy.com/course/grafana-tutorial/learn/lecture/29547784#content

- Visualisation Options
  - https://udemy.com/course/grafana-tutorial/learn/lecture/16345152#content

- Graph Panel : Overrides
  - https://udemy.com/course/grafana-tutorial/learn/lecture/23900928#content

- Graph Panel : Transformations
  - https://udemy.com/course/grafana-tutorial/learn/lecture/23902818#content

- Stat Pane
  - https://udemy.com/course/grafana-tutorial/learn/lecture/18682690#content

- Table Panel
  - https://udemy.com/course/grafana-tutorial/learn/lecture/16356698#content



___

## Data Source, Collector and Dashboard

- Create MySQL Data Source, Collector and Dashboard
  - https://udemy.com/course/grafana-tutorial/learn/lecture/16365592#content

- Create a Custom MySQL Time Series Query
  - https://udemy.com/course/grafana-tutorial/learn/lecture/16543938#content

- Graphing Non Time Series SQL Data in Grafana
  - https://udemy.com/course/grafana-tutorial/learn/lecture/17380378#content

- Install Loki Binary and Start as a Service
  - https://udemy.com/course/grafana-tutorial/learn/lecture/16700594#content


___

## Prometheus

- Install Prometheus Service and Data Source
  - https://udemy.com/course/grafana-tutorial/learn/lecture/16757020#content



___

# Grafana - Machine Learning 

- https://grafana.com/docs/grafana-cloud/machine-learning/

Grafana Machine Learning gives Grafana Cloud users the ability to create predictions of the current or future state of their systems.

To create predictions, you define a source query (the time series to be modeled) and the configuration for the machine learning model. The system will train the model in the background.

Once a model has been successfully trained, you can issue queries to predict the value of the series at different times into the future. The model will also return the confidence bounds for the predicted values.

Over time the model will keep learning new patterns, so it automatically evolves along with your data.


 