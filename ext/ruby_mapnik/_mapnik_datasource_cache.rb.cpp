/*****************************************************************************
 * 
 * Copyright (C) 2011 Elliot Laster
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 *
 *****************************************************************************/
#include "_mapnik_datasource_cache.rb.h"

// Rice
#include <rice/Data_Type.hpp>
#include <rice/Constructor.hpp>
#include <rice/Class.hpp>
#include <rice/Array.hpp>
#include <rice/Hash.hpp>

// Mapnik
#include <mapnik/datasource.hpp>
#include <mapnik/datasource_cache.hpp>

namespace {
  bool rubysafe_register_sources(std::string path){
    mapnik::datasource_cache::instance()->register_datasources(path);
    return true;
  }

  Rice::Array rubysafe_plugin_names(){
    std::vector<std::string, std::allocator<std::string> > names = mapnik::datasource_cache::instance()->plugin_names();

    Rice::Array o;

    int unsigned count = names.size();
    
    for (unsigned i=0;i<count;++i){
      Rice::String n = names[i];
      o.push(n);
    }
    
    return o;
  }
}
void register_datasource_cache(Rice::Module rb_mapnik) {
  /*
    @@Module_var rb_mapnik = Mapnik
  */
  Rice::Data_Type< mapnik::datasource_cache > rb_cdatasource_cache =  Rice::define_class_under< mapnik::datasource_cache >(rb_mapnik, "DatasourceCache");
  
  /*
  * Document-method: available_plugins
  *
  * @return [Array] the datasource plugins available. (Determined by your Mapnik install)
  */
  rb_cdatasource_cache.define_singleton_method("available_plugins", &rubysafe_plugin_names);  
  
  /*
  * Document-method: register
  * call-seq:
  *   Mapnik::DatasourceCache.register(path_to_mapnik_input_plugins)
  * @param [String] The path
  * 
  * Registers the input plugins with mapnik. Used internally by Ruby-Mapnik. 
  * You should never have to call this. 
  */
  rb_cdatasource_cache.define_singleton_method("register", &rubysafe_register_sources, Rice::Arg("path"));
}