# Copyright (C) 2011-2012, InSTEDD
# 
# This file is part of Remindem.
# 
# Remindem is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# Remindem is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with Remindem.  If not, see <http://www.gnu.org/licenses/>.

class BreadcrumbBuilder < BreadcrumbsOnRails::Breadcrumbs::Builder
  
  def render
    "<ul>#{@elements.map{|e| "<li>#{item e}</li>"}.join}</ul>"
  end
  
  def item element
    @context.link_to_unless_current(compute_name(element), compute_path(element))
  end
  
end