--麻花卷猫★味美喵奖品
function c41800042.initial_effect(c)
	--synchro summon
	c:EnableReviveLimit()
	aux.AddSynchroMixProcedure(c,c41800042.matfilter1,nil,nil,c41800042.matfilter2,1,1)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SYNCHRO_LEVEL_EX)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e0:SetTarget(c41800042.syntg)
	e0:SetValue(c41800042.synval)
	c:RegisterEffect(e0)
    --哈基米我拿没鲁多
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41800042,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c41800042.condition)
	e1:SetTarget(c41800042.target)
	e1:SetOperation(c41800042.operation)
	e1:SetCountLimit(1,41800042)
	c:RegisterEffect(e1)
    --阿西噶呀耶库奶龙
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(41800042,1))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c41800042.discon)
	e2:SetCost(c41800042.discost)
	e2:SetTarget(c41800042.distg)
	e2:SetOperation(c41800042.disop)
	e2:SetCountLimit(1,41800142)
	c:RegisterEffect(e2)
end
function c41800042.matfilter1(c,syncard)
	return c:IsTuner(syncard) or c:IsType(TYPE_LINK) and c:IsLink(1)
end
function c41800042.matfilter2(c,syncard)
	return c:IsNotTuner(syncard) and not c:IsType(TYPE_LINK)
end
function c41800042.syntg(e,c)
	return c:IsType(TYPE_LINK) and c:IsLink(1)
end
function c41800042.synval(e,syncard)
	if e:GetHandler()==syncard then
		return 1
	else
		return 0
	end
end
--①效果条件：同调召唤成功
function c41800042.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end

--①效果目标
function c41800042.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_BEAST) and c:IsAttribute(ATTRIBUTE_LIGHT)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c41800042.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c41800042.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

--①效果处理
function c41800042.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c41800042.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
--②效果无效
function c41800042.discon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
function c41800042.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToExtraAsCost() end
	Duel.SendtoDeck(e:GetHandler(),nil,0,REASON_COST)
end
function c41800042.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function c41800042.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end