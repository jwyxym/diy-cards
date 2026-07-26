-- 创炎构曲-三角分形
local s,id,o=GetID()
function s.initial_effect(c)
	-- ①：响应炎属性/「创炎」卡效果发动，自身及手卡/墓地/卡组怪兽当作永续魔法放置
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.tfcon)
	e1:SetCost(s.tfcost)
	e1:SetTarget(s.tftg)
	e1:SetOperation(s.tfop)
	c:RegisterEffect(e1)

	-- ②：送墓场合进行1只炎属性连接怪兽的连接召唤
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id+o*100)
	e2:SetCost(s.lksumcost)
	e2:SetTarget(s.lksumtg)
	e2:SetOperation(s.lksumop)
	c:RegisterEffect(e2)
end

-- 誓约限制逻辑注册（炎属性限制 + 额外卡组仅连接怪兽）
function s.splimit1(e,c,sump,sumtype,sumpos,target_p,se)
	return not c:IsAttribute(ATTRIBUTE_FIRE)
end

function s.splimit2(e,c,sump,sumtype,sumpos,target_p,se)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_LINK)
end

function s.regop(e,tp)
	-- 限制只能召唤/特召炎属性怪兽
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	Duel.RegisterEffect(e2,tp)
	-- 限制额外卡组只能特召连接怪兽
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetTarget(s.splimit2)
	Duel.RegisterEffect(e3,tp)
end

-- ①效果：触发条件（修正：使用原生 IsSetCard 判定「创炎」字段）
function s.tfcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return rp==tp and (re:IsActiveType(TYPE_MONSTER) and rc:IsAttribute(ATTRIBUTE_FIRE) or rc:IsSetCard(0xd85))
end

-- ①效果 Cost：自身当作永续魔法卡放置到魔陷区
function s.tfcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 校验魔陷区空格：自身占用 1 格，后续效果至少需要 1 格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>=2
		and not c:IsForbidden() end
	s.regop(e,tp)
	Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	local e1=Effect.CreateEffect(c)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
	e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
	c:RegisterEffect(e1)
end

-- ①效果过滤：手卡/墓地的炎属性怪兽
function s.pfilter1(c)
	return c:IsType(TYPE_MONSTER) and c:IsAttribute(ATTRIBUTE_FIRE) and not c:IsForbidden()
end

-- ①效果过滤：卡组同等级的「创炎」怪兽 (修正：使用原生 IsSetCard 判定字段)
function s.pfilter2(c,lv)
	return c:IsSetCard(0xd85) and c:IsType(TYPE_MONSTER) and c:IsLevel(lv) and not c:IsForbidden()
end

function s.tftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.pfilter1,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,e:GetHandler()) end
end

function s.tfop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g1=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.pfilter1),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	local tc1=g1:GetFirst()
	if tc1 and Duel.MoveToField(tc1,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		tc1:RegisterEffect(e1)

		-- 检查选中的怪兽是否有等级，且魔陷区是否还有空位
		local lv=tc1:GetLevel()
		if lv>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			and Duel.IsExistingMatchingCard(s.pfilter2,tp,LOCATION_DECK,0,1,nil,lv)
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
			local g2=Duel.SelectMatchingCard(tp,s.pfilter2,tp,LOCATION_DECK,0,1,1,nil,lv)
			local tc2=g2:GetFirst()
			if tc2 and Duel.MoveToField(tc2,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
				local e2=Effect.CreateEffect(e:GetHandler())
				e2:SetCode(EFFECT_CHANGE_TYPE)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
				e2:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
				tc2:RegisterEffect(e2)
			end
		end
	end
end

-- ②效果：Cost / Target / Operation
function s.lksumcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	s.regop(e,tp)
end

function s.lkfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsType(TYPE_LINK) and c:IsLinkSummonable(nil)
end

function s.lksumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.lkfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.lksumop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.lkfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.LinkSummon(tp,tc,nil)
	end
end