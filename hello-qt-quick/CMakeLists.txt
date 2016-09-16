find_package(Qt5Core REQUIRED)
find_package(Qt5Gui REQUIRED)
find_package(Qt5Qml REQUIRED)

set(CMAKE_AUTOMOC ON)
set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(INCLUDE_DIRS
  ${Qt5Gui_INCLUDE_DIRS}
  ${Qt5Core_INCLUDE_DIRS})
set(LIBRARIES
  Qt5::Core
  Qt5::Gui
  Qt5::Qml)

set(SOURCES main.cpp)
set(QRC qml.qrc)
qt5_add_resources(RESOURCES ${QRC})

include_directories(${INCLUDE_DIRS})
add_executable(hellomingw ${SOURCES} ${RESOURCES})
target_link_libraries(hellomingw PUBLIC ${LIBRARIES})
