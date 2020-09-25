#
# General
#
EXEC = demo
CXX = g++
CXXFLAGS = -std=c++11 -Wall -Wextra -Werror -fmax-errors=3 $(INCLUDES) $(LINKDIRS)
CC = $(CXX)
CFLAGS = $(CXXFLAGS)

INCLUDES = -Iinclude
LINKDIRS =
LDFLAGS = 
LIBS =
LINKAGE = $(LIBS) $(LDFLAGS)
SRC_FILES = $(EXEC).cpp $(wildcard src/*.cpp)
		
OBJ = $(SRC_FILES:%.cpp=%.o)
DEP = $(OBJ:%.o=%.d)

#
# Debug build settings
#
DBGDIR = debug
DBGEXEC = $(DBGDIR)/$(EXEC)
DBGOBJ = $(addprefix $(DBGDIR)/, $(OBJ))
DBGDEP = $(addprefix $(DBGDIR)/, $(DEP))
DBGCFLAGS = -g -O0 -DDEBUG -DCANDLE_DEBUG

#
# Release build settings
#
RELDIR = release
RELEXEC = $(RELDIR)/$(EXEC)
RELOBJ = $(addprefix $(RELDIR)/, $(OBJ))
RELDEP = $(addprefix $(RELDIR)/, $(DEP))
RELCFLAGS = -O3 -DNDEBUG

#
# Libraries
#
# SFML
LIBS += -lsfml-graphics -lsfml-window -lsfml-audio -lsfml-system

#
# Custom output functions
#
define print_info
	@echo "\033[1;38;2;250;250;50m$(1)\033[0m"
endef
define print_success
	@echo "\033[1;38;2;50;250;50m$(1)\033[0m"
endef

#
# Rules
#
.PHONY: all debug prep release remake clean clean-release clean-debug docs

# Default build
all: release

# Include dependency rules
-include $(DBGDEP)
-include $(RELDEP)

#
# Debug rules
#
debug: prep $(DBGEXEC)

$(DBGEXEC): $(DBGOBJ)
	$(call print_info,Building $@)
	@$(CXX) $(CXXFLAGS) $(DBGCFLAGS) $^ -o $(DBGEXEC) $(LINKAGE)
	$(call print_success,$< ready)

$(DBGDIR)/%.d: %.cpp
	$(call print_info,Checking debug dependencies for $<)
	$(CPP) $(CFLAGS) $< -MM -MT $(@:.d=.o) >$@
	@echo '\t$$(call print_info,Building $$@)' >> $@
	@echo '\t$$(CXX) -c $$(CXXFLAGS) $$(DBGCFLAGS) -o $$@ $$<' >> $@

# $(DBGDIR)/%.o: %.cpp
# 	$(call print_info,Building $@)
# 	$(CXX) -c $(CXXFLAGS) $(DBGCFLAGS) -o $@ $<

#
# Release rules
#
release: prep $(RELEXEC)
	
$(RELEXEC): $(RELOBJ)
	$(call print_info,Building $@)
	$(CXX) $(CXXFLAGS) $(RELCFLAGS) $^ -o $(RELEXEC) $(LINKAGE)
	$(call print_success,$< ready)

$(RELDIR)/%.d: %.cpp
	$(call print_info,Checking release dependencies for $<)
	$(CPP) $(CFLAGS) $< -MM -MT $(@:.d=.o) >$@
	@echo '\t$$(call print_info,Building $$@)' >> $@
	@echo '\t$$(CXX) -c $$(CXXFLAGS) $$(RELCFLAGS) -o $$@ $$<' >> $@
	
# $(RELDIR)/%.o: %.cpp
# 	$(call print_info,Building $@)
# 	$(CXX) -c $(CXXFLAGS) $(RELCFLAGS) -o $@ $<
	
#
# Other rules
#
prep:
	@mkdir -p $(DBGDIR)/src
	@mkdir -p $(RELDIR)/src

remake: clean all

clean: clean-release clean-debug

clean-release:
	@rm -f -r $(RELDIR)
	@mkdir -p $(RELDIR)/src
clean-debug:
	@rm -f -r $(DBGDIR)
	@mkdir -p $(DBGDIR)/src
# 
# Documentation rules
# 

DOXYFILE = doc/Doxyfile
	
docs:
	@doxygen $(DOXYFILE)
	
