--异质绝望-摇奖机
local m=35100143
local cm=_G["c"..m]
function cm.initial_effect(c)
	aux.AddCodeList(c,35100109)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,m)
	e1:SetTarget(cm.thtg)
	e1:SetOperation(cm.thop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,m+1)
	e2:SetTarget(cm.tktg)
	e2:SetOperation(cm.tkop)
	c:RegisterEffect(e2)
end
function cm.thfilter(c)
	return c:IsSetCard(0xa91) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function cm.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.thfilter,tp,LOCATION_DECK,0,3,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function cm.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(cm.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>=3 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,3,3,nil)
		Duel.ConfirmCards(1-tp,sg)
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)
		local tc=sg:RandomSelect(1-tp,1):GetFirst()
		Duel.ShuffleDeck(tp)
		if Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsSetCard(0x5a92) then
			local zg=Duel.GetMatchingGroup(cm.filter3,tp,LOCATION_HAND,0,nil,e,tp)
			if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and zg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(m,2)) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local zc=zg:Select(tp,1,1,nil):GetFirst()
				Duel.SpecialSummon(zc,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
function cm.filter3(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_WARRIOR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function cm.tktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=3 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
function cm.thfilter2(c)
	return c:IsSetCard(0xa91) and c:IsAbleToHand()
end
function cm.tkop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ConfirmDecktop(tp,3)
	local g=Duel.GetDecktopGroup(tp,3)
	if g:GetCount()>0 then
		if g:IsExists(Card.IsSetCard,1,nil,0xa91) then
			if g:IsExists(cm.thfilter2,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(m,1)) then
				Duel.Hint(HINT_SELECTMSG,p,HINTMSG_ATOHAND)
				local sg=g:FilterSelect(tp,cm.thfilter2,1,1,nil)
				Duel.SendtoHand(sg,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,sg)
				Duel.ShuffleHand(tp)
			end
		end
		Duel.ShuffleDeck(tp)
	end
end