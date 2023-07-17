import React, { useCallback, useMemo, useState } from "react";

import {
  cilCalendarCheck,
  cilClipboard,
  cilClock,
  cilGlobeAlt,
  cilWindowRestore,
} from "@coreui/icons";
import CIcon from "@coreui/icons-react";
import { CCard, CCardBody, CCardHeader, CCol, CRow } from "@coreui/react";
import { CChart } from "@coreui/react-chartjs";

import MetricCardComponent from "../../../components/common/MetricCardComponent/MetricCardComponent";
import {
  TasksMetricsProps,
  UsersMetricsProps,
  getTasksMetrics,
  getUsersMetrics,
} from "../../../Controllers/AnalyticsController/AnalyticsApi";
import { languageTLAMap } from "../../../utils/commonUtils";

import styles from "./analytics.module.scss";

const TaskMetrics: {
  icon: JSX.Element;
  name: string;
  propertyName: keyof TasksMetricsProps;
}[] = [
  {
    icon: (
      <div className={styles.iconContainerDiv}>
        <CIcon
          icon={cilClipboard}
          height={100}
          width={100}
          className={styles.iconStyle}
        />
      </div>
    ),
    name: "Total Requests",
    propertyName: "totalTasks",
  },
  {
    icon: (
      <div className={styles.iconContainerDiv}>
        <CIcon
          icon={cilClock}
          height={100}
          width={100}
          className={styles.iconStyle}
        />
      </div>
    ),
    name: "Pending Requests",
    propertyName: "totalPendingTasks",
  },
  {
    icon: (
      <div className={styles.iconContainerDiv}>
        <CIcon
          icon={cilCalendarCheck}
          height={100}
          width={100}
          className={styles.iconStyle}
        />
      </div>
    ),
    name: "Completed Requests",
    propertyName: "totalCompletedTasks",
  },
  {
    icon: (
      <div className={styles.iconContainerDiv}>
        <CIcon
          icon={cilWindowRestore}
          height={100}
          width={100}
          className={styles.iconStyle}
        />
      </div>
    ),
    name: "Average Requests per day",
    propertyName: "averagePerDay",
  },
];

const Analytics = (): JSX.Element => {
  const [tasksMetrics, setTasksMetrics] = useState({
    loaded: false,
    data: {} as TasksMetricsProps,
  });
  const [usersMetrics, setUsersMetrics] = useState({
    loaded: false,
    data: {} as UsersMetricsProps,
  });
  const [showTaskMetrics, setShowTaskMetrics] = useState(true);
  const tasksMetricsFetch = useCallback(() => {
    getTasksMetrics()
      .then(({ data }) => {
        setTasksMetrics((currentValue) => ({
          ...currentValue,
          loaded: true,
          data: data,
        }));
      })
      .catch(({ response }) => {
        window.alert(response.data.error.message);
      });
  }, []);

  const usersMetricsFetch = useCallback(() => {
    getUsersMetrics()
      .then(({ data }) => {
        setUsersMetrics((currentValue) => ({
          ...currentValue,
          loaded: true,
          data: data,
        }));
      })
      .catch(({ response }) => {
        window.alert(response.data.error.message);
      });
  }, []);

  useMemo(() => {
    tasksMetricsFetch();
  }, [tasksMetricsFetch]);

  useMemo(() => {
    usersMetricsFetch();
  }, [usersMetricsFetch]);

  const renderTasksMetricsCards = (): JSX.Element[] | null => {
    if (!tasksMetrics.loaded) {
      return null;
    }
    return TaskMetrics.map(({ icon, name, propertyName }) => (
      <CCol key={name} className={styles.metricColStyle}>
        <MetricCardComponent
          icon={icon}
          cardStyle={styles.requestMetricsCardStyle}
          cardBodyStyle={styles.requestMetricsCardBodyStyle}
          title={tasksMetrics.data[propertyName] as unknown as number}
          titleStyle={styles.requestMetricsTitleStyle}
          value={name}
          valueStyle={styles.requestMetricsValueStyle}
          color="primary"
        />
      </CCol>
    ));
  };

  const renderRequestTypes = (): JSX.Element | null => {
    if (!tasksMetrics.loaded) {
      return null;
    }
    return (
      <>
        <CCol>
          <CCard className={styles.userTypesCardStyle}>
            <CCardHeader className={styles.userTypesHeaderStyle}>
              Request Types
            </CCardHeader>
            <CCardBody>
              <CChart
                type="bar"
                data={{
                  labels: [
                    "Keep Company",
                    "Shopping",
                    "Pharmacies",
                    "Tours",
                    "Other",
                  ],
                  datasets: [
                    {
                      label: "Request Types",
                      backgroundColor: [
                        "#0D3B66",
                        "#0D3B66",
                        "#0D3B66",
                        "#0D3B66",
                        "#0D3B66",
                      ],
                      data: [
                        tasksMetrics.data.taskTypeGroups.company,
                        tasksMetrics.data.taskTypeGroups.shopping,
                        tasksMetrics.data.taskTypeGroups.pharmacy,
                        tasksMetrics.data.taskTypeGroups.tours,
                        tasksMetrics.data.taskTypeGroups.other,
                      ],
                      hoverOffset: 10,
                    },
                  ],
                }}
                customTooltips={false}
              />
            </CCardBody>
          </CCard>
        </CCol>
        <CCol>
          <CCard className={styles.userTypesCardStyle}>
            <CCardHeader className={styles.userTypesHeaderStyle}>
              Request Ratings
            </CCardHeader>
            <CCardBody>
              <CChart
                type="bar"
                data={{
                  labels: [
                    "1 star",
                    "2 stars",
                    "3 stars",
                    "4 stars",
                    "5 stars",
                  ],

                  datasets: [
                    {
                      label: "Request ratings",
                      backgroundColor: [
                        "#C93046",
                        "#FDA943",
                        "#FDCA43",
                        "#E0D62E",
                        "#A2B414",
                      ],
                      data: [
                        tasksMetrics.data.ratingBreakdown[1],
                        tasksMetrics.data.ratingBreakdown[2],
                        tasksMetrics.data.ratingBreakdown[3],
                        tasksMetrics.data.ratingBreakdown[4],
                        tasksMetrics.data.ratingBreakdown[5],
                      ],
                      hoverOffset: 10,
                    },
                  ],
                }}
                options={{ plugins: { legend: { display: false } } }}
                customTooltips={false}
              />
            </CCardBody>
          </CCard>
        </CCol>
      </>
    );
  };

  const renderUsersMetricsCards = (): JSX.Element | null => {
    if (!usersMetrics.loaded) {
      return null;
    }
    return (
      <>
        <CCol>
          <CCard className={styles.userTypesCardStyle}>
            <CCardHeader className={styles.userTypesHeaderStyle}>
              User Types
            </CCardHeader>
            <CCardBody>
              <CChart
                type="pie"
                data={{
                  labels: ["Elders", "Volunteers"],
                  datasets: [
                    {
                      backgroundColor: ["#FE6D73", "#0D3B66"],
                      data: [
                        usersMetrics.data.totalElders,
                        usersMetrics.data.totalVolunteers,
                      ],
                      hoverOffset: 10,
                    },
                  ],
                }}
                customTooltips={false}
              />
            </CCardBody>
          </CCard>
        </CCol>
        <CCol>
          <CCard className={styles.userTypesCardStyle}>
            <CCardHeader className={styles.userTypesHeaderStyle}>
              Verified Users
            </CCardHeader>
            <CCardBody>
              <CChart
                type="pie"
                data={{
                  labels: ["Total", "Verified", "Pending", "Rejected"],
                  datasets: [
                    {
                      backgroundColor: [
                        "#899CAD",
                        "#35AB68",
                        "#FDA943",
                        "#C93046",
                      ],
                      data: [
                        usersMetrics.data.totalUsers,
                        usersMetrics.data.totalVerifiedUsers,
                        usersMetrics.data.totalUsers -
                          usersMetrics.data.totalVerifiedUsers,
                        0,
                      ],
                      hoverOffset: 10,
                    },
                  ],
                }}
                customTooltips={false}
              />
            </CCardBody>
          </CCard>
        </CCol>
      </>
    );
  };

  const renderAgeGroupsMetricsCards = (): JSX.Element | null => {
    if (!usersMetrics.loaded) {
      return null;
    }
    return (
      <>
        <CCol>
          <CCard className={styles.userTypesCardStyle}>
            <CCardHeader className={styles.userTypesHeaderStyle}>
              Age Groups
            </CCardHeader>
            <CCardBody>
              <CChart
                type="bar"
                data={{
                  labels: [
                    "<18",
                    "18 to 25",
                    "26 to 30",
                    "31 to 40",
                    "41 to 60",
                    "61 to 75",
                    ">75",
                  ],
                  datasets: [
                    {
                      label: "Registered users age group",
                      backgroundColor: [
                        "#FE6D73",
                        "#FE6D73",
                        "#FE6D73",
                        "#FE6D73",
                        "#FE6D73",
                        "#FE6D73",
                        "#FE6D73",
                      ],
                      data: [
                        usersMetrics.data.ageGroups["age<18"],
                        usersMetrics.data.ageGroups["18<=age<25"],
                        usersMetrics.data.ageGroups["25<=age<30"],
                        usersMetrics.data.ageGroups["30<=age<40"],
                        usersMetrics.data.ageGroups["40<=age<60"],
                        usersMetrics.data.ageGroups["60<=age<75"],
                        usersMetrics.data.ageGroups["age>=75"],
                      ],
                    },
                  ],
                }}
                customTooltips={false}
                options={{
                  scales: {
                    y: {
                      min: 0,
                      ticks: {
                        stepSize: 1,
                      },
                      grace: 2,
                    },
                  },
                }}
              />
            </CCardBody>
          </CCard>
        </CCol>
        <CCol>
          <CCard className={styles.userTypesCardStyle}>
            <CCardHeader className={styles.userTypesHeaderStyle}>
              Gender
            </CCardHeader>
            <CCardBody>
              <CChart
                type="bar"
                data={{
                  labels: ["Male", "Female", "Others"],
                  datasets: [
                    {
                      label: "Registered users gender",
                      backgroundColor: ["#474954", "#474954", "#474954"],
                      data: [
                        usersMetrics.data.genderCount.m,
                        usersMetrics.data.genderCount.f,
                        usersMetrics.data.genderCount.x,
                      ],
                    },
                  ],
                }}
                customTooltips={false}
                options={{
                  scales: {
                    y: {
                      min: 0,
                      ticks: {
                        stepSize: 1,
                      },
                      grace: 2,
                    },
                  },
                }}
              />
            </CCardBody>
          </CCard>
        </CCol>
      </>
    );
  };

  const renderLanguageMetricsCards = (): JSX.Element | null => {
    if (
      !usersMetrics.loaded ||
      !Object.keys(usersMetrics.data.languageCount).length
    ) {
      return null;
    }
    return (
      <>
        <div className={styles.languageSubTitleStyle}>Language</div>
        <CRow md={{ cols: 4 }}>
          {Object.entries(usersMetrics.data.languageCount).map(
            ([name, value]) => (
              <CCol key={name} className={styles.metricColStyle}>
                <MetricCardComponent
                  icon={
                    <div className={styles.globeIconContainerDiv}>
                      <CIcon
                        icon={cilGlobeAlt}
                        height={100}
                        width={100}
                        className={styles.globeIconStyle}
                      />
                    </div>
                  }
                  cardStyle={styles.requestMetricsCardStyle}
                  cardBodyStyle={styles.requestMetricsCardBodyStyle}
                  title={value}
                  titleStyle={styles.requestMetricsTitleStyle}
                  value={languageTLAMap[name]}
                  valueStyle={styles.requestMetricsValueStyle}
                />
              </CCol>
            )
          )}
        </CRow>
      </>
    );
  };

  const renderMetrics = (): JSX.Element => {
    if (showTaskMetrics) {
      return (
        <div>
          <div className={styles.pageSubTitleStyle}>Requests Metrics</div>
          <CRow md={{ cols: 4 }}>{renderTasksMetricsCards()}</CRow>
          <CRow md={{ cols: 2 }}>{renderRequestTypes()}</CRow>
        </div>
      );
    }
    return (
      <>
        <div>
          <div className={styles.pageSubTitleStyle}>User Metrics</div>
          <CRow md={{ cols: 2 }} className={styles.metricContainerRow}>
            {renderUsersMetricsCards()}
          </CRow>
          <CRow md={{ cols: 2 }} className={styles.metricContainerRow}>
            {renderAgeGroupsMetricsCards()}
          </CRow>
        </div>
        <div></div>
        <div> {renderLanguageMetricsCards()}</div>
      </>
    );
  };

  return (
    <>
      <div className={styles.pageTitleStyle}>
        Analytics
        <div className={styles.metricTypeSelectionDiv}>
          <div
            onClick={() => setShowTaskMetrics(() => true)}
            className={
              showTaskMetrics
                ? styles.activeTaskMetricTypeStyle
                : styles.taskMetricTypeStyle
            }
          >
            Requests
          </div>
          <div
            onClick={() => setShowTaskMetrics(() => false)}
            className={
              !showTaskMetrics
                ? styles.activeUserMetricTypeStyle
                : styles.userMetricTypeStyle
            }
          >
            Users
          </div>
        </div>
      </div>
      {renderMetrics()}
    </>
  );
};

export default Analytics;
