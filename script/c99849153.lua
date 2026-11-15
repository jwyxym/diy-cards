--梦魔镜的幻世-摩耳甫斯
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,74665651,1050355,99849154)
	c:EnableReviveLimit()


	aux.AddFusionProcFunRep(c,s.ffilter,3,true)


	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA)

	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	-- ① 
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)

	-- ② 
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DAMAGE+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END+TIMING_BATTLE_START+TIMING_BATTLE_END)
	e3:SetCountLimit(1,id+10000)
	e3:SetCondition(s.spcon2)
	e3:SetCost(s.cost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop2)
	c:RegisterEffect(e3)

	-- ③ 
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_DAMAGE+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END+TIMING_BATTLE_START+TIMING_BATTLE_END)
	e4:SetCountLimit(1,id+20000)
	e4:SetCondition(s.spcon3)
	e4:SetCost(s.cost)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
end

-- ======================================



function s.ffilter(c,fc,sumtype,tp)
	return c:IsSetCard(0x131,fc,sumtype,tp)
		and c:IsType(TYPE_MONSTER)
		
end

-- ======================================



function s.rmfilter(c)
	return c:IsCode(99849154)
		and c:IsFaceup()
		and c:IsAbleToRemoveAsCost()
end



function s.has_rm_target(tp)
	return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_MZONE,0,1,nil)
end


function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
		and s.has_rm_target(tp)
end


function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_MZONE,0,1,1,nil)
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end

-- ==================== ① ====================



function s.field_filter(c)
	return c:IsType(TYPE_FIELD)
end



function s.atkval(e,c)
	local g=Duel.GetMatchingGroup(s.field_filter,0,
		LOCATION_ONFIELD+LOCATION_GRAVE,
		LOCATION_ONFIELD+LOCATION_GRAVE,
		nil)
	return g:GetCount()*1000
end

-- ==================== ② ====================



function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsEnvironment(74665651,PLAYER_ALL,LOCATION_FZONE)
end



function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable() end
	Duel.Release(c,REASON_COST)
end



function s.spfilter2(c,e,tp)
	return c:IsSetCard(0x131)
		and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end



function s.has_sp_target(tp,e)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp)
end


function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return s.has_sp_target(tp,e)
	end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end


function s.spop2(e,tp,eg,ep,ev,re,r,rp)
 
	if Duel.Damage(1-tp,1000,REASON_EFFECT)<=0 then return end

	if not s.has_sp_target(tp,e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

-- ==================== ③ 检测函数 ====================



function s.spcon3(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsEnvironment(1050355,PLAYER_ALL,LOCATION_FZONE)
end



function s.thfilter(c)
	return c:IsSetCard(0x131)
		and c:IsType(TYPE_SPELL+TYPE_TRAP)
		and c:IsAbleToHand()
end



function s.has_th_target(tp)
	return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
end


function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return s.has_th_target(tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end


function s.thop(e,tp,eg,ep,ev,re,r,rp)
   
	if Duel.Damage(1-tp,1000,REASON_EFFECT)<=0 then return end
 
	if not s.has_th_target(tp) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end