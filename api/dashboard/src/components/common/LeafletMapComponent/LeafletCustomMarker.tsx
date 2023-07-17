import { divIcon } from "leaflet";

export const CustomMapMarker = divIcon({
  html: `<svg xmlns="http://www.w3.org/2000/svg">
  <circle cx="10" cy="10" r="7" fill="#fe6d73" stroke="#ffffff" stroke-width="2"/>
</svg>`,
  className: "dummy",
  iconSize: [14, 14],
  iconAnchor: [10, 10],
});
