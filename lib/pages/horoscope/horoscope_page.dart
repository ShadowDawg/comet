import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test1/colors.dart';
import 'package:test1/models/user.dart';
import 'package:test1/pages/horoscope/horoscope_widgets.dart';
import 'package:test1/providers/user_data_provider.dart';

class HoroscopePage extends StatefulWidget {
  const HoroscopePage({Key? key}) : super(key: key);

  @override
  _HoroscopePageState createState() => _HoroscopePageState();
}

class _HoroscopePageState extends State<HoroscopePage> {
  bool _isCheckingConnectivity = true;
  bool _hasInternetConnection = true;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (mounted) {
      setState(() {
        _isCheckingConnectivity = false;
        _hasInternetConnection = connectivityResult != ConnectivityResult.none;
      });
    }
  }

  Future<void> _refreshData() async {
    await _checkConnectivity();
    if (_hasInternetConnection && mounted) {
      await Provider.of<UserDataProvider>(context, listen: false)
          .refreshUserData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgcolor,
      appBar: AppBar(
        toolbarHeight: kToolbarHeight + MediaQuery.of(context).padding.top,
        automaticallyImplyLeading: false,
        backgroundColor: bgcolor,
        flexibleSpace: SafeArea(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              // double height = constraints.maxHeight.isFinite
              //     ? constraints.maxHeight
              //     : MediaQuery.of(context).size.height * 0.1;
              double height = kToolbarHeight * 1.4;
              double fontSize = height * 0.4;

              return Container(
                height: height,
                padding: EdgeInsets.symmetric(
                  horizontal: constraints.maxWidth * 0.05,
                  vertical: height * 0.1,
                ),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xFFC0C0BE),
                    ),
                  ),
                ),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Text(
                      'comet.',
                      style: TextStyle(
                        fontFamily: 'Playwrite_HU',
                        fontSize: fontSize,
                        color: yelloww, // Ensure this color is defined
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isCheckingConnectivity) {
      return _buildLoadingWidget();
    } else if (!_hasInternetConnection) {
      return _buildNoInternetWidget();
    } else {
      return _buildHoroscopeContent();
    }
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: offwhite),
          SizedBox(height: 16),
          Text(
            'Aligning with the stars...',
            style: TextStyle(color: offwhite, fontFamily: 'Manrope'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoInternetWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, size: 60, color: offwhite),
          const SizedBox(height: 16),
          const Text(
            'No Internet Connection',
            style:
                TextStyle(color: offwhite, fontSize: 18, fontFamily: 'Manrope'),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please check your connection and try again.',
            style:
                TextStyle(color: offwhite, fontSize: 14, fontFamily: 'Manrope'),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _checkConnectivity,
            style: ElevatedButton.styleFrom(backgroundColor: yelloww),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildHoroscopeContent() {
    return Consumer<UserDataProvider>(
      builder: (context, userDataProvider, child) {
        if (userDataProvider.isLoading) {
          return _buildLoadingWidget();
        }

        final UserModel? userData = userDataProvider.userData;

        if (userData == null) {
          return _buildErrorWidget(
              'Unable to load user data. Please try again later.');
        }

        // error widget is being shown even if userData is there but some
        // refresh error, better to only show error if userData is empty.
        // Commenting this out.
        // Edit: show a snack bar saying unable to refresh bruv.
        // if (userDataProvider.error != null) {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     const SnackBar(
        //         content: Text(
        //       'Failed to refresh data. Please check your internet connection.',
        //     )),
        //   );
        // }

        double avatarRadius = MediaQuery.of(context).size.width * 0.15;
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: <Widget>[
              // GreetingWidget(userName: userData.user.name),
              // SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: HoroscopeCard(
                  photoUrl: userData.photoUrl,
                  avatarRadius: avatarRadius,
                  horoscope: userData.astroData.dailyHoroscope,
                  userName: userData.name,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  color: yelloww,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child:
                        ActionTable(tableData: userData.astroData.actionTable),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: offwhite),
          const SizedBox(height: 16),
          const Text(
            'Oops! Something went wrong.',
            style:
                TextStyle(color: offwhite, fontSize: 18, fontFamily: 'Manrope'),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
                color: offwhite, fontSize: 14, fontFamily: 'Manrope'),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refreshData,
            style: ElevatedButton.styleFrom(backgroundColor: yelloww),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}

class ActionTable extends StatelessWidget {
  final Map<String, List<String>> tableData;

  const ActionTable({
    Key? key,
    required this.tableData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double fontSizeEntry = MediaQuery.of(context).size.width * 0.05;
    double fontSizeHeader = MediaQuery.of(context).size.width * 0.08;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: Icon(
                Icons.done_rounded,
                size: fontSizeHeader,
                color: Colors.green,
              ),
            ),
            Expanded(
              child: Icon(
                Icons.cancel_rounded,
                size: fontSizeHeader,
                color: Colors.red,
              ),
            ),
          ],
        ),
        for (int i = 0; i < (tableData['yes']?.length ?? 0); i++)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: Text(
                  tableData['yes']?[i] ?? '',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: fontSizeEntry,
                    // fontWeight: FontWeight.w600,
                    color: bgcolor,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  tableData['no']?[i] ?? '',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: fontSizeEntry,
                    // fontWeight: FontWeight.w600,
                    color: bgcolor,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
