IF(STM32_FAMILY STREQUAL "F4")
  SET(STD_COMPONENTS adc can cec crc cryp dac dbgmcu dcmi dfsdm dma2d dma dsi
      exti flash flash_ramfunc fmc fmpi2c fsmc gpio hash i2c iwdg lptim ltdc
      pwr qspi rcc rng rtc sai sdio spdifrx spi syscfg tim usart wwdg)

  SET(STD_REQUIRED_COMPONENTS dma dma2d fmc i2c ltdc gpio rcc spi usart
      adc tim exti syscfg)

  SET(STD_EX_COMPONENTS cryp hash)

  SET(STD_PREFIX stm32f4xx_)
ENDIF()

SET(STD_HEADERS
    misc.h
    stm32f4xx.h
    core_cm4.h
    )

SET(STD_SRCS
    misc.c
    )

IF(NOT STM32STDPERIPH_FIND_COMPONENTS)
  SET(STM32STDPERIPH_FIND_COMPONENTS ${STD_COMPONENTS})
  MESSAGE(STATUS "No STM32STD components selected, using all: ${STM32STD_FIND_COMPONENTS}")
ENDIF()

FOREACH(cmp ${STD_REQUIRED_COMPONENTS})
  LIST(FIND STM32STDPERIPH_FIND_COMPONENTS ${cmp} STM32STD_FOUND_INDEX)
  IF(${STM32STD_FOUND_INDEX} LESS 0)
    LIST(APPEND STM32STDPERIPH_FIND_COMPONENTS ${cmp})
  ENDIF()
ENDFOREACH()

FOREACH(cmp ${STM32STD_FIND_COMPONENTS})
  LIST(FIND STD_COMPONENTS ${cmp} STM32STD_FOUND_INDEX)
  IF($STM32STD_FOUND_INDEX LESS 0)
    MESSAGE(FATAL_ERROR "Unknown STM32STD Peripheral component: ${cmp}. Available components: ${STD_COMPONENTS}")
  ELSE()
    LIST(APPEND STD_HEADERS ${STD_PREFIX}${cmp}.h)
    LIST(APPEND STD_SRCS ${STD_PREFIX}${cmp}.c)
  ENDIF()
  LIST(FIND STD_EX_COMPONENTS ${cmp} STM32STD_FOUND_INDEX)
  IF(NOT (${STM32STD_FOUND_INDEX} LESS 0))
    STRING(COMPARE EQUAL ${cmp} "cryp" STM32_EQUAL)
    IF(${STM32_EQUAL})
      LIST(APPEND STD_SRCS ${STD_PREFIX}${cmp}_aes.c)
      LIST(APPEND STD_SRCS ${STD_PREFIX}${cmp}_des.c)
      LIST(APPEND STD_SRCS ${STD_PREFIX}${cmp}_tdes.c)
    ENDIF()
    STRING(COMPARE EQUAL ${cmp} "hash" STM32_EQUAL)
    IF(${STM32_EQUAL})
      LIST(APPEND STD_SRCS ${STD_PREFIX}${cmp}_md5.c)
      LIST(APPEND STD_SRCS ${STD_PREFIX}${cmp}_sha1.c)
    ENDIF()
  ENDIF()
ENDFOREACH()

LIST(REMOVE_DUPLICATES STD_HEADERS)
LIST(REMOVE_DUPLICATES STD_SRCS)

FOREACH(HEADER ${STD_HEADERS})
  FIND_PATH(STM32STD_${HEADER}_INCLUDE_DIR
            NAMES ${HEADER}
            PATHS
            ${STM32STD_DIR}/Libraries/CMSIS/Device/ST/STM32F4xx/Include
            ${STM32STD_DIR}/Libraries/CMSIS/Include
            ${STM32STD_DIR}/Libraries/STM32F4xx_StdPeriph_Driver/inc
            CMAKE_FIND_ROOT_PATH_BOTH
            )
  LIST(APPEND STM32STD_INCLUDE_DIR ${STM32STD_${HEADER}_INCLUDE_DIR})
ENDFOREACH()

SET(SRC_HINTS_DIR
    ${STM32STD_DIR}/Libraries/STM32${STM32_FAMILY}xx_StdPeriph_Driver/src)

FOREACH(STD_SRC ${STD_SRCS})
  STRING(MAKE_C_IDENTIFIER "${STD_SRC}" STD_SRC_CLEAN)
  SET(STD_${STD_SRC_CLEAN}_FILE STD_SRC_FILE-NOTFOUND)
  FIND_FILE(STD_${STD_SRC_CLEAN}_FILE ${STD_SRC}
            PATH_SUFFIXES src
            HINTS ${SRC_HINTS_DIR}
            CMAKE_FIND_ROOT_PATH_BOTH
    )
  LIST(APPEND STM32STD_SOURCES ${STD_${STD_SRC_CLEAN}_FILE})
ENDFOREACH()

LIST(REMOVE_DUPLICATES STM32STD_INCLUDE_DIR)

INCLUDE(FindPackageHandleStandardArgs)

FIND_PACKAGE_HANDLE_STANDARD_ARGS(STM32STD DEFAULT_MSG
                                  STM32STD_INCLUDE_DIR STM32STD_SOURCES)
