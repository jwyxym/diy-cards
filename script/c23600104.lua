-- 创炎谱系-十字绣分 (ID: 23600104)
local s,id,o=GetID()
local SET_CHOUEN=0xd85 -- 「创炎」字段

function s.initial_effect(c)
	-- ①：当作永续魔法卡使用的场合才能发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_LEAVE_GRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)

	-- ②：这张卡被送去墓地的场合才能发动（【关键修复】：彻底移除 CATEGORY_DECKDES，不再吃灰流丽！）
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_LEAVE_GRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id+o*100)
	e2:SetCost(s.cost)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)

	-- 全局计数注册：监听全回合非炎属性怪兽的召唤·特殊召唤
	Duel.AddCustomActivityCounter(id,ACTIVITY_SUMMON,s.counterfilter)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end

-- 全局炎属性计数器过滤
function s.counterfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE)
end

-- 共同誓约代价检查与施加（全回合非炎属性召唤·特召封锁）
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SUMMON)==0
		and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	Duel.RegisterEffect(e2,tp)
end
function s.splimit(e,c,sump,sumtype,sumpos,target_p,se)
	return not c:IsAttribute(ATTRIBUTE_FIRE)
end

-- ①效果：作为永续魔法卡使用的状态判定
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_SZONE) and c:IsType(TYPE_SPELL) and c:IsType(TYPE_CONTINUOUS)
end

-- ①效果：放置怪兽过滤（墓地·除外状态的「创炎」怪兽）
function s.plfilter1(c)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
		and c:IsSetCard(SET_CHOUEN) and c:IsType(TYPE_MONSTER)
		and not c:IsForbidden()
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.plfilter1,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.plfilter1),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	local tc=g:GetFirst()
	if tc and Duel.MoveToField(tc,tp,tc:GetOwner(),LOCATION_SZONE,POS_FACEUP,true) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
	end

	-- 这个回合，自己不是连接怪兽不能从额外卡组特殊召唤
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetTargetRange(1,0)
	e2:SetTarget(s.exlimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
end

function s.exlimit(e,c,sump,sumtype,sumpos,target_p,se)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_LINK)
end

-- ②效果：放置怪兽过滤（手卡·卡组·墓地·除外状态的「创炎」怪兽）
function s.plfilter2(c)
	return (c:IsLocation(LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE) or c:IsFaceup())
		and c:IsSetCard(SET_CHOUEN) and c:IsType(TYPE_MONSTER)
		and not c:IsForbidden()
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.plfilter2,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.plfilter2),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	local tc=g:GetFirst()
	if tc and Duel.MoveToField(tc,tp,tc:GetOwner(),LOCATION_SZONE,POS_FACEUP,true) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
	end
end