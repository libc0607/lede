cmake_minimum_required (VERSION 2.8)

project (ezwifibroadcast)

add_definitions(-Wall -D _GNU_SOURCE)

add_executable(rx  rx.c  lib.c  radiotap.c  fec.c)
target_link_libraries(rx rt pcap)
install (TARGETS rx DESTINATION bin)

add_executable(rx_rc_telemetry  rx_rc_telemetry.c  lib.c  radiotap.c)
target_link_libraries(rx_rc_telemetry rt pcap)
install (TARGETS rx_rc_telemetry DESTINATION bin)

add_executable(rx_rc_telemetry_buf  rx_rc_telemetry_buf.c  lib.c  radiotap.c)
target_link_libraries(rx_rc_telemetry_buf rt pcap)
install (TARGETS rx_rc_telemetry DESTINATION bin)

add_executable(rssirx  rssirx.c  lib.c  radiotap.c )
target_link_libraries(rssirx rt pcap)
install (TARGETS rssirx DESTINATION bin)

add_executable(rssitx  rssitx.c  lib.c  radiotap.c )
target_link_libraries(rssitx rt pcap)
install (TARGETS rssitx DESTINATION bin)

add_executable(tx_rawsock  tx_rawsock.c  lib.c  fec.c)
target_link_libraries(tx_rawsock rt pcap)
install (TARGETS tx_rawsock DESTINATION bin)

add_executable(tx_telemetry  tx_telemetry.c  lib.c  fec.c)
target_link_libraries(tx_telemetry rt pcap)
install (TARGETS tx_telemetry DESTINATION bin)

add_executable(tx_measure  tx_measure.c  lib.c  fec.c)
target_link_libraries(tx_measure rt pcap)
install (TARGETS tx_measure DESTINATION bin)

add_executable(rx_status  rx_status.c)
target_link_libraries(rx_status rt pcap)
install (TARGETS rx_status DESTINATION bin)

add_executable(rssilogger  rssilogger.c)
target_link_libraries(rssilogger rt pcap)
install (TARGETS rssilogger DESTINATION bin)

add_executable(syslogger  syslogger.c)
target_link_libraries(syslogger rt pcap)
install (TARGETS syslogger DESTINATION bin)

add_executable(channelscan  channelscan.c)
target_link_libraries(channelscan rt pcap)
install (TARGETS channelscan DESTINATION bin)

add_executable(check_alive  check_alive.c )
target_link_libraries(check_alive rt pcap)
install (TARGETS check_alive DESTINATION bin)

add_executable(rssi_forward  rssi_forward.c )
target_link_libraries(rssi_forward rt pcap)
install (TARGETS rssi_forward DESTINATION bin)

add_executable(wifiscan  wifiscan.c radiotap.c)
target_link_libraries(wifiscan rt pcap)
install (TARGETS wifiscan DESTINATION bin)

add_executable(wifibackgroundscan  wifibackgroundscan.c radiotap.c)
target_link_libraries(wifibackgroundscan rt pcap)
install (TARGETS wifibackgroundscan DESTINATION bin)

add_executable(sharedmem_init_rx  sharedmem_init_rx.c  lib.c)
target_link_libraries(sharedmem_init_rx rt pcap)
install (TARGETS sharedmem_init_rx DESTINATION bin)

add_executable(sharedmem_init_tx  sharedmem_init_tx.c lib.c)
target_link_libraries(sharedmem_init_tx rt pcap)
install (TARGETS sharedmem_init_tx DESTINATION bin)

add_executable(ftee ftee.c)
target_link_libraries(ftee rt pcap)
install (TARGETS ftee DESTINATION bin)
