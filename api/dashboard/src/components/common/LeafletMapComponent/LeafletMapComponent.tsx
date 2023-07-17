import React, { useRef } from "react";

import { LatLngTuple } from "leaflet";
import { Circle, MapContainer, Marker, TileLayer } from "react-leaflet";

import "leaflet/dist/leaflet.css";

import { CustomMapMarker } from "./LeafletCustomMarker";
import styles from "./leafletMapComponent.module.scss";

interface LeafletMapComponentProps {
  coordinates: LatLngTuple;
  radius: number;
}

const LeafletMapComponent: React.FC<LeafletMapComponentProps> = ({
  coordinates,
  radius,
}) => {
  const isCoordinateValid = useRef(false);
  const isCoordinatesValid = (): number => {
    if (coordinates.every((coordinate) => !coordinate)) {
      return 1;
    }
    isCoordinateValid.current = true;
    return 10;
  };

  const renderMarker = (): JSX.Element => {
    if (isCoordinateValid.current) {
      return (
        <>
          <Marker position={coordinates} icon={CustomMapMarker} />
          <Circle
            center={coordinates}
            radius={radius * 1000}
            fillColor="#FE6D73"
            fillOpacity={0.2}
            color="#FE6D73"
          />
        </>
      );
    }
    return <></>;
  };

  return (
    <MapContainer
      center={coordinates}
      zoom={isCoordinatesValid()}
      scrollWheelZoom={false}
      className={styles.mapContainerStyle}
    >
      <TileLayer
        url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
        attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
      />
      {renderMarker()}
    </MapContainer>
  );
};

export default LeafletMapComponent;
