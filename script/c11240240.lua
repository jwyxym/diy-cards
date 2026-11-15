local s,id,o=GetID()
function s.initial_effect(c)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e0:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCountLimit(1,id+1)
	e2:SetCondition(function() return Duel.IsMainPhase() end)
	e2:SetCost(s.cost)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
function s.thfilter(c)
	return c:IsSetCard(0xf03) and c:IsRace(RACE_MACHINE) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) then
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
	if not c:IsStatus(STATUS_SET_TURN) and Duel.IsExistingMatchingCard(Card.IsSummonable,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,true,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
		local sg=Duel.SelectMatchingCard(tp,Card.IsSummonable,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,true,nil)
		if #sg>0 then
			Duel.Summon(tp,sg:GetFirst(),true,nil)
		end
	end
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeckAsCost() end
	Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetCondition(s.otcon)
	e1:SetTarget(s.ottg)
	e1:SetOperation(s.otop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.otfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToGrave()
end
function s.otcheck(c)
	local tp=c:GetControler()
	local mi=c:GetTributeRequirement()
	if mi<=0 then return false end
	local dg=Duel.GetMatchingGroup(s.otfilter,tp,LOCATION_DECK,0,nil)
	if #dg==0 then return false end
	local fg=Duel.GetTributeGroup(c)
	local lcount=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local my_fg=0
	for tc in aux.Next(fg) do
		if tc:IsControler(tp) and tc:GetSequence()<5 then
			my_fg=my_fg+1
		end
	end
	for k=1,math.min(#dg,mi) do
		local rem=mi-k
		if rem==0 and lcount>0 then return true end
		if rem>0 and #fg>=rem and (lcount>0 or my_fg>0) then return true end
	end
	return false
end
function s.otcon(e,c,minc)
	if c==nil then return true end
	return s.otcheck(c)
end
function s.ottg(e,c)
	return s.otcheck(c)
end
function s.otop(e,tp,eg,ep,ev,re,r,rp,c)
	local mi=c:GetTributeRequirement()
	local dg=Duel.GetMatchingGroup(s.otfilter,tp,LOCATION_DECK,0,nil)
	local fg=Duel.GetTributeGroup(c)
	local lcount=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local my_fg=0
	for tc in aux.Next(fg) do
		if tc:IsControler(tp) and tc:GetSequence()<5 then
			my_fg=my_fg+1
		end
	end
	local rel_deck=Group.CreateGroup()
	local rel_field=Group.CreateGroup()
	for i=1,mi do
		local rem=mi-i
		local can_deck=#dg>0 and (rem>0 or lcount>0)
		local can_field=#fg>0 and (#rel_deck>0 or rem<=#dg) and (lcount>0 or my_fg>0)
		local opt=0
		if can_deck and can_field then
			opt=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
		elseif can_deck then
			opt=0
		else
			opt=1
		end
		if opt==0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local tc=dg:Select(tp,1,1,nil):GetFirst()
			rel_deck:AddCard(tc)
			dg:RemoveCard(tc)
		else
			local sel_fg=fg
			if lcount<=0 and rem==0 and #rel_deck>0 then
				sel_fg=Group.CreateGroup()
				for tc in aux.Next(fg) do
					if tc:IsControler(tp) and tc:GetSequence()<5 then
						sel_fg:AddCard(tc)
					end
				end
			end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
			local tc=sel_fg:Select(tp,1,1,nil):GetFirst()
			rel_field:AddCard(tc)
			fg:RemoveCard(tc)
			if tc:IsControler(tp) and tc:GetSequence()<5 then
				lcount=lcount+1
				my_fg=my_fg-1
			end
		end
	end
	local mat=Group.CreateGroup()
	mat:Merge(rel_deck)
	mat:Merge(rel_field)
	c:SetMaterial(mat)
	if #rel_deck>0 then
		Duel.SendtoGrave(rel_deck,REASON_RELEASE+REASON_SUMMON+REASON_MATERIAL)
	end
	if #rel_field>0 then
		Duel.Release(rel_field,REASON_SUMMON+REASON_MATERIAL)
	end
	e:Reset()
end