--命运女郎·奥尔
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
   
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsType,TYPE_TUNER),
		aux.NonTuner(aux.FilterBoolFunction(Card.IsSetCard,0x31)),3,99)

  
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.synlimit)
	c:RegisterEffect(e0)

   
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
	e2:SetCode(EFFECT_SET_ATTACK_FINAL)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)

	local e3=e2:Clone()
	e3:SetCode(EFFECT_SET_DEFENSE_FINAL)
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
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EFFECT_IMMUNE_EFFECT)
	e5:SetCondition(s.imcon13)
	e5:SetValue(s.immval13)
	c:RegisterEffect(e5)

  
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,2))
	e6:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetCode(EVENT_CHAINING)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1,id+20000)
	e6:SetCondition(s.negcon15)
	e6:SetCost(s.negcost)
	e6:SetTarget(s.negtg15)
	e6:SetOperation(s.negop15)
	c:RegisterEffect(e6)
end

-- ======================================


function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end


function s.spfilter(c,e,tp)
	return c:IsSetCard(0x31)
		and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end


function s.has_sp_target(tp,e)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp)
end


function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return s.has_sp_target(tp,e)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end


function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ct=math.min(3, Duel.GetLocationCount(tp,LOCATION_MZONE))
	if ct<=0 then return end
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_REMOVED,0,nil,e,tp)
	if g:GetCount()==0 then return end

  
	local avail={}
	local seen={}
	local tc=g:GetFirst()
	while tc do
		local code=tc:GetOriginalCode()
		if not seen[code] then
			seen[code]=true
			table.insert(avail,tc)
		end
		tc=g:GetNext()
	end

	if #avail==0 then return end
	local actual_ct=math.min(ct,#avail)

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=Group.FromCards(table.unpack(avail)):Select(tp,1,actual_ct,nil)

	if sg:GetCount()>0 then
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end

-- ==================== ② ==================


function s.atkval(e,c)
	return c:GetLevel()*400
end

-- ==================== ③ ====================


function s.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end


function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	local lv=c:GetLevel()
  
	if lv<12 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
   
	Duel.Draw(tp,1,REASON_EFFECT)
end

-- ==================== ④-1 ====================


function s.imcon13(e)
	return e:GetHandler():GetLevel()>=13
end


function s.immval13(e,te)
  
	if te:GetOwnerPlayer()==e:GetHandlerPlayer() then return false end
	local rc=te:GetHandler()
	if not rc then return false end
	return rc:IsType(TYPE_MONSTER)
end

-- ==================== ④-2 ===================


function s.negcon15(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetLevel()>=15
		and rp==1-tp
		and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
		and Duel.IsChainNegatable(ev)
end


function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:GetLevel()>=3
	end
   
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
	local rc=re:GetHandler()
	if Duel.NegateActivation(ev) and rc and rc:IsRelateToEffect(re) then
		Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)
	end
end