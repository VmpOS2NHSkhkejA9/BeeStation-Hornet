import { useBackend, useSharedState } from '../backend';
import { AnimatedNumber, Box, Button, Flex, LabeledList, Section, Table, Tabs, Divider, NoticeBox } from '../components';
import { formatMoney, formatTime } from '../format';
import { Window } from '../layouts';

// so aggressively, obnoxiously wide. I don't like this, but I also don't have a better solution
export const CargoBountyConsole = (props) => {
  return (
    <Window width={650} height={900}>
      <Window.Content scrollable>
        <CargoContent />
      </Window.Content>
    </Window>
  );
};

const CargoContent = (props) => {
  const { act, data } = useBackend();
  const [tab, setTab] = useSharedState('tab', 'contracts');
  return (
    <Box>
      <CargoStatusLite />
      <Section fitted>
        <Tabs>
          <Tabs.Tab icon="dolly" selected={tab === 'contracts'} onClick={() => setTab('contracts')}>
            Supply Contracts
          </Tabs.Tab>
          <Tabs.Tab icon="chart-column" selected={tab === 'exportrates'} onClick={() => setTab('exportrates')}>
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
  const { act, data } = useBackend();
  const [tab, setTab] = useSharedState('contracttab', 'available');
  const { reputation } = data;
  const available_bounties = data.available_bounties || [];
  const active_bounties = data.active_bounties || [];
  const archived_bounties = data.archived_bounties || [];
  return (
    <Box>
      <Section fitted>
        <Tabs vertical>
          <Tabs.Tab fontSize={1.25} icon="file-contract" selected={tab === 'available'} onClick={() => setTab('available')}>
            Available ({available_bounties.length})
          </Tabs.Tab>
          <Tabs.Tab fontSize={1.25} icon="bookmark" selected={tab === 'accepted'} onClick={() => setTab('accepted')}>
            Accepted ({active_bounties.length})
          </Tabs.Tab>
          <Tabs.Tab fontSize={1.25} icon="box-archive" selected={tab === 'archived'} onClick={() => setTab('archived')}>
            Archived ({archived_bounties.length})
          </Tabs.Tab>
        </Tabs>
      </Section>
      {reputation < 0 && (
        <NoticeBox danger bold>
          NOTICE: Continued failure of accepted contracts will result in penalty.
        </NoticeBox>
      )}

      {tab === 'available' && <CargoContractsAvailable />}
      {tab === 'accepted' && <CargoContractsAccepted />}
      {tab === 'archived' && <CargoContractsArchived />}
    </Box>
  );
};

const CargoContractsAvailable = (props) => {
  const { act, data } = useBackend();
  const available_bounties = data.available_bounties || [];
  return (
    <Section title="Available Contracts" textAlign="center">
      <Flex wrap="wrap" justify="space-between">
        {!available_bounties.length && (
          <Flex.Item grow>
            <NoticeBox>There are no contracts available at this time.</NoticeBox>
          </Flex.Item>
        )}
        {available_bounties.map((bounty) => (
          <Flex key={bounty.reference} maxWidth="300px" wrap="wrap" direction="row" p={2}>
            <Section
              title={bounty.title}
              className="BountyConsole_Entry_Available"
              backgroundColor="rgb(20, 20, 20)"
              textAlign="center">
              <LabeledList>
                <LabeledList.Item label="Author">{bounty.author}</LabeledList.Item>
                <LabeledList.Item label="Note">{bounty.description}</LabeledList.Item>
                <LabeledList.Item label="Expires in">
                  <AnimatedNumber value={bounty.timeremaining - 1} format={(value) => formatTime(value, 'short')} />
                </LabeledList.Item>
              </LabeledList>
              <Divider />
              <Box backgroundColor="rgba(0,0,0,255)" p={2}>
                {bounty.completion}
              </Box>
              <Divider />
              <Flex>
                <Flex.Item align="center" textAlign="left" bold grow>
                  {'Reward: '}
                  <AnimatedNumber value={bounty.reward} format={(value) => formatMoney(value)} />
                  {' credits'}
                </Flex.Item>
                <Flex.Item align="center" pr={1}>
                  <Button
                    icon="check"
                    color="good"
                    content="Accept"
                    onClick={() => act('Accept', { reference: bounty.reference })}
                  />
                </Flex.Item>
              </Flex>
            </Section>
          </Flex>
        ))}
      </Flex>
    </Section>
  );
};

const CargoContractsAccepted = (props) => {
  const { act, data } = useBackend();
  const active_bounties = data.active_bounties || [];
  return (
    <Section title="Accepted Contracts" textAlign="center">
      <Flex wrap="wrap" justify="space-between">
        {!active_bounties.length && (
          <Flex.Item grow>
            <NoticeBox>
              You do not have any active contracts at this time. More may be available in the &quot;Available&quot; tab.
            </NoticeBox>
          </Flex.Item>
        )}
        {active_bounties.map((bounty) => (
          <Flex key={bounty.reference} maxWidth="300px" wrap="wrap" direction="row" p={2}>
            <Section
              title={bounty.title}
              className="BountyConsole_Entry_Active"
              backgroundColor="rgb(20, 20, 20)"
              textAlign="center">
              <LabeledList>
                <LabeledList.Item label="Author">{bounty.author}</LabeledList.Item>
                <LabeledList.Item label="Note">{bounty.description}</LabeledList.Item>
                <LabeledList.Item label="Expires in">
                  <AnimatedNumber value={bounty.timeremaining - 1} format={(value) => formatTime(value, 'short')} />
                </LabeledList.Item>
              </LabeledList>
              <Divider />
              <Box backgroundColor="rgba(0,0,0,255)" p={2}>
                {bounty.completion}
              </Box>
              <Divider />
              <Flex>
                <Flex.Item align="center" textAlign="left" lineHeight="20px" bold grow>
                  {'Reward: '}
                  <AnimatedNumber value={bounty.reward} format={(value) => formatMoney(value)} />
                  {' credits'}
                </Flex.Item>
              </Flex>
            </Section>
          </Flex>
        ))}
      </Flex>
    </Section>
  );
};

const CargoContractsArchived = (props) => {
  const { act, data } = useBackend();
  const archived_bounties = data.archived_bounties || [];
  return (
    <Section title="Archived Contracts" textAlign="center">
      <Flex wrap="wrap" justify="space-between">
        {!archived_bounties.length && (
          <Flex.Item grow>
            <NoticeBox>You have not failed or completed any contracts this shift.</NoticeBox>
          </Flex.Item>
        )}
        {archived_bounties.map((bounty) => (
          <Flex key={bounty.reference} maxWidth="300px" wrap="wrap" direction="row" p={2}>
            <Section
              title={bounty.title}
              className={bounty.status === 3 ? 'BountyConsole_Entry_Completed' : 'BountyConsole_Entry_Failed'}
              backgroundColor="rgb(20, 20, 20)"
              textAlign="center">
              <LabeledList>
                <LabeledList.Item label="Author">{bounty.author}</LabeledList.Item>
                <LabeledList.Item label="Note">{bounty.description}</LabeledList.Item>
              </LabeledList>
              <Divider />
              <NoticeBox success={bounty.status === 3} danger={bounty.status !== 3} p={2}>
                {bounty.completion}
              </NoticeBox>
              <Divider />
              <Flex>
                <Flex.Item align="center" textAlign="left" lineHeight="20px" bold grow>
                  {'Reward: '}
                  <AnimatedNumber value={bounty.reward} format={(value) => formatMoney(value)} />
                  {' credits'}
                </Flex.Item>
              </Flex>
            </Section>
          </Flex>
        ))}
      </Flex>
    </Section>
  );
};

// crude and simple, but it works and communicates what it needs to.
const CargoExportRates = (props) => {
  const { act, data } = useBackend();
  const rates = data.exportrates || [];
  return (
    <Section title="Export Rates">
      <Table>
        <Table.Row bold color="label" fontSize={1.25} nowrap>
          <Table.Cell p={1} textAlign="center">
            Export Category
          </Table.Cell>
          <Table.Cell p={1} textAlign="center" nowrap>
            Description
          </Table.Cell>
          <Table.Cell p={1} textAlign="center" nowrap>
            Rate (%)
          </Table.Cell>
        </Table.Row>
        {rates.map((rate) => (
          <Table.Row key={rate.name} className="BountyConsole_Rate">
            <Table.Cell bold p={1}>
              {rate.name}
            </Table.Cell>
            <Table.Cell italic textAlign="center" p={1} textColor="label">
              {rate.desc}
            </Table.Cell>
            <Table.Cell
              bold
              p={1}
              textAlign="center"
              textColor={rate.multiplier > 110 ? 'green' : rate.multiplier < 90 ? 'bad' : 'average'}>
              <Button
                color="rgba(0,0,0,0)"
                tooltip="The value of selling this type of good, compared to its standard value"
                textColor={rate.multiplier > 110 ? 'green' : rate.multiplier < 90 ? 'bad' : 'average'}>
                {rate.multiplier}%
              </Button>
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};
