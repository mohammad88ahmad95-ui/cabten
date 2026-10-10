import 'package:flutter/material.dart';

import '../presentation/auth/otp_verify.dart';
import '../presentation/auth/phone_login.dart';
import '../presentation/booking_flow/booking_flow.dart';
import '../presentation/booking_management/booking_management.dart';
import '../presentation/home_browse/home_browse.dart';
import '../presentation/notifications/notifications_screen.dart';
import '../presentation/provider_home/provider_account.dart';
import '../presentation/provider_home/provider_bookings.dart';
import '../presentation/provider_home/provider_home.dart';
import '../presentation/provider_home/provider_news.dart';
import '../presentation/provider_home/provider_reports.dart';
import '../presentation/provider_onboarding/provider_onboarding.dart';
import '../presentation/provider_panel/provider_panel.dart';
import '../presentation/role_selection/role_selection.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/vendor_booking_management/vendor_booking_management.dart';
import '../presentation/vendor_detail_profile/vendor_detail_profile.dart';

class AppRoutes {
  static const String initial = '/';
  static const String phoneLogin = '/phone-login';
  static const String otpVerify = '/otp-verify';
  static const String roleSelection = '/role-selection';
  static const String home = '/home';
  static const String notifications = '/notifications';
  static const String providerPanel = '/provider-panel';
  static const String providerOnboarding = '/provider-onboarding';
  static const String providerHome = '/provider-home';
  static const String providerAccount = '/provider-account';
  static const String providerReports = '/provider-reports';
  static const String providerBookings = '/provider-bookings';
  static const String providerNews = '/provider-news';
  static const String vendorDashboard = '/vendor-dashboard';
  static const String vendorDetailProfile = '/vendor-detail-profile';
  static const String vendorBookingManagement = '/vendor-booking-management';
  static const String bookingFlow = '/booking-flow';
  static const String bookingManagement = '/booking-management';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    phoneLogin: (context) => const PhoneLogin(),
    otpVerify: (context) => const OtpVerify(),
    roleSelection: (context) => const RoleSelection(),
    home: (context) => const HomeBrowse(),
    notifications: (context) => const NotificationsScreen(),
    providerPanel: (context) => const ProviderPanel(),
    providerOnboarding: (context) => const ProviderOnboarding(),
    providerHome: (context) => const ProviderHome(),
    providerAccount: (context) => const ProviderAccount(),
    providerReports: (context) => const ProviderReports(),
    providerBookings: (context) => const ProviderBookings(),
    providerNews: (context) => const ProviderNews(),
    vendorDashboard: (context) => const ProviderHome(),
    vendorDetailProfile: (context) => const VendorDetailProfile(),
    vendorBookingManagement: (context) => const VendorBookingManagement(),
    bookingFlow: (context) => const BookingFlow(),
    bookingManagement: (context) => const BookingManagement(),
  };
}
