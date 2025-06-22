import { useBackend, useSharedState } from '../backend';
import { AnimatedNumber, Box, Button, Flex, LabeledList, Section, Table, Tabs } from '../components';
import { formatMoney } from '../format';
import { Window } from '../layouts';

export const CargoBountyConsole = (props) => {
  return (
    <Window width={585} height={750}>
      <Window.Content scrollable>
        <CargoContent />
      </Window.Content>
    </Window>
  );
};

const CargoContent = (props) => {
  const { act, data } = useBackend();
  const [tab, setTab] = useSharedState('tab', 'contracts');
  const { requestonly } = data;
  const cart = data.cart || [];
  const requests = data.requests || [];
  return (
    <Box>
      <CargoStatusLite />
      <Section fitted>
        <Tabs>
          <Tabs.Tab icon="list" selected={tab === 'contracts'} onClick={() => setTab('contracts')}>
            Supply Contracts
          </Tabs.Tab>
          <Tabs.Tab icon="envelope" selected={tab === 'exportrates'} onClick={() => setTab('exportrates')}>
            Export Rates
          </Tabs.Tab>
        </Tabs>
      </Section>
      {tab === 'contracts' && <CargoContracts />}
      {tab === 'exportrates' && <CargoExportRates />}
    </Box>
  );
};

// trimmed down version of the regular order console's header
const CargoStatusLite = (props) => {
  const { act, data } = useBackend();
  const { location, message, points } = data;
  return (
    <Section
      title="Cargo"
      buttons={
        <Box fontFamily="verdana" inline bold>
          <AnimatedNumber value={points} format={(value) => formatMoney(value)} />
          {' credits'}
        </Box>
      }>
      <LabeledList>
        <LabeledList.Item label="Shuttle">{location}</LabeledList.Item>
        <LabeledList.Item label="CentCom Message">{message}</LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const CargoContracts = (props) => {
  return <Section title="Supply Contracts" />;
};

// this looks completely awful right now but it works until I begin to comprehend the gibberish humanity calls tgui
const CargoExportRates = (props) => {
  const { act, data } = useBackend();
  const rates = data.exportrates || [];
  return (
    <Section title="Export Rates">
      <Table>
        <Table.Row bold italic color="label" fontSize={1.25}>
          <Table.Cell p={1} textAlign="center">
            Export Category
          </Table.Cell>
          <Table.Cell p={1} textAlign="center">
            Description
          </Table.Cell>
          <Table.Cell p={1} textAlign="center">
            Current Rate
          </Table.Cell>
        </Table.Row>
        {rates.map((rate) => (
          <Table.Row key={rate.name}>
            <Table.Cell bold p={1}>
              {rate.name}
            </Table.Cell>
            <Table.Cell italic textAlign="center" p={1}>
              {rate.desc}
            </Table.Cell>
            <Table.Cell bold p={1} textAlign="center">
              {rate.multiplier}%
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};
