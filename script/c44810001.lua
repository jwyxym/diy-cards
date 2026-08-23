--次元魔盗 小约翰
local s,id,o=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+id)
	e3:SetTarget(s.rmtg)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetCondition(s.indcon)
	e4:SetValue(aux.tgoval)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(s.indcon)
	e5:SetValue(aux.indoval)
	c:RegisterEffect(e5)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_DECK,0,3,nil,0x3ce1) end
end
function s.indcon(e)
	return e:GetHandler():GetEquipGroup():IsExists(Card.IsSetCard,1,nil,0x3ce1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_DECK,0,3,nil,0x3ce1) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=Duel.SelectMatchingCard(tp,Card.IsSetCard,tp,LOCATION_DECK,0,3,3,nil,0x3ce1)
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleDeck(tp)
		local tc=g:GetFirst()
		while tc do
			Duel.SendtoDeck(tc,1-tp,SEQ_DECKTOP,REASON_EFFECT)
			tc=g:GetNext()
		end
		Duel.SortDecktop(tp,1-tp,3)
		local sc=g:GetFirst()
		while sc do
			Duel.MoveSequence(sc,SEQ_DECKBOTTOM)
			sc=g:GetNext()
		end
	end
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetDecktopGroup(1-tp,1)
	if chk==0 then return #g>0 end
end
function s.rmfilter(c)
	return c:IsAbleToHand() and c:IsSetCard(0x3ce1)
end
function s.bgfilter(c,ct)
	return c:GetSequence()<ct
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsPlayerCanRemove(tp) then return end
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)
	if ct>4 then ct=4 end
	if ct>1 then
		local tbl={}
		for i=1,ct do
			table.insert(tbl,i)
		end
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
		ct=Duel.AnnounceNumber(tp,table.unpack(tbl))
	end
	local bg=Duel.GetFieldGroup(1-tp,LOCATION_DECK,0):Filter(s.bgfilter,nil,ct)
	local sc=bg:GetFirst()
	while sc do
		Duel.MoveSequence(sc,SEQ_DECKTOP)
		sc=bg:GetNext()
	end
	Duel.ConfirmDecktop(1-tp,ct)
	local g=Duel.GetDecktopGroup(1-tp,ct)
	if g:IsExists(s.rmfilter,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	Duel.RevealSelectDeckSequence(true)
	local sg=g:FilterSelect(tp,s.rmfilter,1,1,nil)
	Duel.RevealSelectDeckSequence(false)
	if #sg>0 then
		Duel.DisableShuffleCheck(true)
		if Duel.SendtoHand(sg,tp,REASON_EFFECT)~=0 then
			Duel.DisableShuffleCheck(false)
			Duel.ConfirmCards(1-tp,sg)
			if g:IsExists(s.rmfilter,1,sg) and Duel.SelectYesNo(1-tp,aux.Stringid(id,4)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			Duel.RevealSelectDeckSequence(true)
			local sg1=g:FilterSelect(1-tp,s.rmfilter,1,1,sg)
			Duel.RevealSelectDeckSequence(false)
			if #sg1>0 then
				Duel.DisableShuffleCheck(true)
				if Duel.SendtoHand(sg1,1-tp,REASON_EFFECT)~=0 then
				Duel.DisableShuffleCheck(false)
				Duel.ConfirmCards(tp,sg1)
				end
			end
		end
		end
	end
	end
	local bc=g:GetFirst()
	while bc do
		Duel.MoveSequence(bc,SEQ_DECKBOTTOM)
		bc=g:GetNext()
	end
end