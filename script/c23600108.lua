-- 创炎之构-六角棱雪
local s,id,o=GetID()
function s.initial_effect(c)
	-- link summon：「创炎」怪兽2只以上
	aux.AddLinkProcedure(c,s.matfilter,2)
	c:EnableReviveLimit()

	-- 魔陷区的表侧表示炎属性怪兽当作连接素材
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_EXTRA_LINK_MATERIAL)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetTargetRange(LOCATION_SZONE,0)
	e1:SetValue(s.matval)
	c:RegisterEffect(e1)

	-- 连接召唤成功时的召唤限制监听
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(s.regcon)
	e0:SetOperation(s.regop)
	c:RegisterEffect(e0)

	-- ①：这张卡不会成为对方的效果的对象
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)

	-- ②：场上有怪兽召唤·特召的场合，以场上1只怪兽为对象当作永续魔法放置
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o*100)
	e3:SetTarget(s.tftg2)
	e3:SetOperation(s.tfop2)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)

	-- ③：从魔陷区特殊召唤的场合，选场上·墓地1只怪兽当作永续魔法放置
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_LEAVE_GRAVE+CATEGORY_GRAVE_ACTION)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetCountLimit(1,id+o*200)
	e5:SetCondition(s.tfcon3)
	e5:SetTarget(s.tftg3)
	e5:SetOperation(s.tfop3)
	c:RegisterEffect(e5)
end

-- 素材过滤：「创炎」怪兽 (修正：IsSetCode 改为 IsSetCard，且兼容魔陷区的原本怪兽)
function s.matfilter(c,lc,sumtype,tp)
	return c:IsSetCard(0xd85) and (c:IsType(TYPE_MONSTER,lc,sumtype,tp) or c:IsOriginalType(TYPE_MONSTER))
end

-- 魔陷区表侧炎属性怪兽作素材判定 (修正：使用 IsOriginalType 判断原本怪兽类型)
function s.matval(e,lc,mg,c,tp)
	if e:GetHandler()~=lc then return false,nil end
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsOriginalType(TYPE_MONSTER),true
end

-- 连接召唤成功时注册誓约限制
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

function s.splimit(e,c,sump,sumtype,sumpos,target_p,se)
	return not c:IsAttribute(ATTRIBUTE_FIRE)
end

function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	Duel.RegisterEffect(e2,tp)
end

-- ②效果：Target / Operation
function s.tffilter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsOnField()
		and Duel.GetLocationCount(c:GetOwner(),LOCATION_SZONE)>0
		and not c:IsForbidden()
end

function s.tftg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.tffilter2(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tffilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.tffilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end

function s.tfop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) and not tc:IsImmuneToEffect(e) then
		local p=tc:GetOwner()
		if Duel.GetLocationCount(p,LOCATION_SZONE)<=0 then return end
		if Duel.MoveToField(tc,tp,p,LOCATION_SZONE,POS_FACEUP,true) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetCode(EFFECT_CHANGE_TYPE)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
			e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
			tc:RegisterEffect(e1)
		end
	end
end

-- ③效果：Condition / Target / Operation
function s.tfcon3(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_SZONE)
end

function s.tffilter3(c)
	return c:IsType(TYPE_MONSTER)
		and (c:IsLocation(LOCATION_MZONE) or c:IsLocation(LOCATION_GRAVE))
		and Duel.GetLocationCount(c:GetOwner(),LOCATION_SZONE)>0
		and not c:IsForbidden()
end

function s.tftg3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tffilter3,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) end
end

function s.tfop3(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tffilter3),tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		local p=tc:GetOwner()
		if Duel.GetLocationCount(p,LOCATION_SZONE)<=0 then return end
		if Duel.MoveToField(tc,tp,p,LOCATION_SZONE,POS_FACEUP,true) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetCode(EFFECT_CHANGE_TYPE)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
			e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
			tc:RegisterEffect(e1)
		end
	end
end