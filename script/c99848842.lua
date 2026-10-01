--命运女郎·奥尔
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()

	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsType,TYPE_TUNER),aux.NonTuner(aux.FilterBoolFunction(Card.IsSetCard,0x31)),3,99)
	

	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	

	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_SET_ATTACK)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_SET_DEFENSE)
	c:RegisterEffect(e3)
	
   
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+10000)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e4:SetCondition(s.lvcon)
	e4:SetOperation(s.lvop)
	c:RegisterEffect(e4)
	

	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_IMMUNE_EFFECT)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(s.imcon13)
	e5:SetValue(s.immfilter)
	c:RegisterEffect(e5)
	

	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,2))
	e6:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetCode(EVENT_CHAINING)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCondition(s.negcon15)
	e6:SetCost(s.negcost)
	e6:SetTarget(s.negtg15)
	e6:SetOperation(s.negop15)
	c:RegisterEffect(e6)
end


function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end


function s.spfilter(c)
	return c:IsSetCard(0x31) and c:IsType(TYPE_MONSTER) and c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_REMOVED,0,nil,e,tp)
	if chk==0 then

		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and g:GetCount()>0
	end
	

	local name_groups={}
	local name_list={}
	local tc=g:GetFirst()
	while tc do
		local name=tc:GetOriginalCode()
		if not name_groups[name] then
			name_groups[name]={}
			table.insert(name_list,name)
		end
		table.insert(name_groups[name],tc)
		tc=g:GetNext()
	end
	

	local ct=math.min(3, Duel.GetLocationCount(tp,LOCATION_MZONE), #name_list)
	Duel.SetTargetParam(ct)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ct,tp,LOCATION_REMOVED)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if ct<=0 then return end
	
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_REMOVED,0,nil,e,tp)
	if g:GetCount()==0 then return end
	
	
	local name_groups={}
	local name_list={}
	local tc=g:GetFirst()
	while tc do
		local name=tc:GetOriginalCode()
		if not name_groups[name] then
			name_groups[name]={}
			table.insert(name_list,name)
		end
		table.insert(name_groups[name],tc)
		tc=g:GetNext()
	end
	
  
	local available_cards={}
	for _,name in ipairs(name_list) do
		local tlist=name_groups[name]
		if tlist and #tlist>0 then
			table.insert(available_cards,tlist[1])
		end
	end
	
	local ct2=math.min(ct, #available_cards, Duel.GetLocationCount(tp,LOCATION_MZONE))
	if ct2<=0 then return end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=Duel.SelectMatchingCard(tp,function(card)
		for _,v in ipairs(available_cards) do
			if v==card then return true end
		end
		return false
	end, tp, LOCATION_REMOVED, 0, 1, ct2, nil)
	
	if sg:GetCount()>0 then
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end


function s.atkval(e,c)
	return c:GetLevel()*400
end


function s.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end

function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	local lv=c:GetLevel()
	if lv>=12 then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	Duel.Draw(tp,1,REASON_EFFECT)
end


function s.imcon13(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetLevel()>=13
end

function s.immfilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:IsActiveType(TYPE_MONSTER)
end


function s.negcon15(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetLevel()>=15 and rp==1-tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainNegatable(ev)
end

function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetLevel()>=3 end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(-3)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
end

function s.negtg15(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,0,0)
end

function s.negop15(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) then
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end